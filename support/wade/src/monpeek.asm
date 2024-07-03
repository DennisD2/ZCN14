	title	'Hardware dependent routines for monitor'
;
;	Last Edited	85-04-19	Wagner
;
;	Copyright (c) 1984, 1985 by
;
;		Thomas Wagner
;		Patschkauer Weg 31
;		1000 Berlin 33
;		West Germany
;
;       Released to the public domain 1987
;
;
;	Hardware dependent routines which concern banking are collected 
;	in this module.
;
;	Extended addressing (used only if equate "extended" is true):
;
;	The monitor uses a 24-bit extended address when accessing memory
;	in all commands. The msb is specified by the user or obtained by
;	currbank.
;	The value FF as msb is used as "default" and may not be used as
;	a normal bank number.
;	In sytems with a 64k address space, the msb may simply be ignored.
;	If the monitor resides in EPROM, and the EPROM address space overlays
;	parts of the normal address space, PEEK, POKE, and GOTO must switch
;	out the EPROM and access real memory instead.
;	In this case, and in any case where banking might switch out 
;	the monitor, you will have to move parts of PEEK, POKE, and GOTO
;	to a common, non-switched area. This may be done by INITSYSTEM.
;
;	GOTO		must enter program memory.
;			If necessary, console interrupts can be re-enabled
;			here.
;	DEBEXIT		is jumped to to exit the monitor. cleanup operations
;			may be performed here.
;
;	The following entries are only needed if "extended" is true:
;
;	PEEK		reads 16 bytes from the extended address specified
;			by A and HL.
;	PEEKS		does the same, but reads into a different buffer.
;	POKE		writes back the 16 bytes read by PEEK.
;
;	CURRBANK	must return the current bank for program execution.
;	XLTBANK		must return the current or the default bank depending
;			on address
;	BANKOK		must set the carry-flag if the bank passed as parameter
;			is not a valid bank.
;
;
restartinst	equ	0ffh	; RST 38
restartloc	equ	38h
;
dfltbnk		equ	1	; default program bank
;
;
	cseg
;
	maclib	z80
	maclib	monopt
;
;
	public	restart,rstloc,debexit,resetrst
;
	IF	extended
	public	peek,poke,peeks,currbank,bankok,xltbank
	public	peekbuf,paddr,pbank,psaddr,psbank
	extrn	cbank
	extrn	breaklist
	ENDIF
	public	inipeek
	public	goto
;
	extrn	next,biosloc
	extrn	regpc,string,regiff,regsp
	extrn	break,nresetbk
	extrn	string,wrhex,wrchar
	extrn	monent,cmderr,eocmd
;
;------------------------------------------------------------------------------
;
;	inipeek:	init module variables & jump locations
;
inipeek:
	IF	extended
	lxi	d,xltscbpar
	mvi	c,49
	call	next			; get common memory base address
	shld	combase
	lhld	biosloc			; set up direct jumps to bios
	lxi	d,24*3
	dad	d
	shld	move+1
	lxi	d,6
	dad	d
	shld	selmem+1
	dad	d
	shld	xmove+1
	ret
;
xltscbpar:
	db	5dh		; scb offset
	db	0		; get operation
;
	ELSE
;
	ret
;
	ENDIF
;
;------------------------------------------------------------------------------
;
	IF	extended
;
;	peek:		read 16 bytes of memory into "peekbuf"
;
;		entry:	A = bank
;			HL = address
;
;		exit:	-
;			(paddr & pbank set, peekbuf filled with 16 bytes)
;
;		uses:	-
;
peek:
	call	xltbank
	sta	pbank
	shld	paddr
	push	d
	lxi	d,peekbuf
peek10:
	push	b
	push	h
	push	psw
	push	h
	push	d
	mov	c,a
	mvi	b,dfltbnk
	call	xmove
	pop	h
	pop	d
	lxi	b,16
	call	move
	pop	psw
	pop	h
	pop	b
	pop	d
	ret
;
;
;	peeks:		read 16 bytes of memory into "string"
;
;		entry:	A = bank
;			HL = address
;
;		exit:	-
;			(psaddr & psbank set, string filled with 16 bytes)
;
;		uses:	-
;
peeks:
	call	xltbank
	sta	psbank
	shld	psaddr
	push	d
	lxi	d,string
	jr	peek10
;
;
;	poke:		write 16 bytes of memory from "peekbuf"
;
;		entry:	-
;
;		exit:	-
;
;		uses:	-
;
poke:
	push	h
	push	d
	push	b
	push	psw
	lda	pbank
	lhld	paddr
	call	xltbank
	push	h
	mov	b,a
	mvi	c,dfltbnk
	call	xmove
	pop	h
	lxi	d,peekbuf
	lxi	b,16
	call	move
	pop	psw
	pop	b
	pop	d
	pop	h
	ret
;
;
;
selmem:
	jmp	0
;
move:
	jmp	0
;
xmove:
	jmp	0
;
;
	ENDIF
;
;	goto:		enter program
;
;		entry:	cbank = bank
;			regpc = address to go to
;			regsp = user stack pointer
;			regiff = interrupt enable flag
;			all registers restored except SP and interrupt status
;			interrupts are disabled.
;
;		exit:	no exit
;
;		uses:	N/A
;
;	NOTE:	this routine must insert a jump to the break-entry at the
;		restart address. If the monitor is in banked memory, this
;		break-entry must be in common.
;
goto:
	push	psw
	push	h
	lhld	regpc
	mov	a,h
	ora	l
	jz	debexit		; jump to 0 means exit debugger
	call	setrst
	pop	h
	IF	extended
	lda	cbank
	call	selmem
	ENDIF
	IF	disint
	lda	regiff
	ani	1
	jrz	gotodi
	ENDIF
	pop	psw
	lspd	regsp
	push	h
	lhld	regpc
	xthl
	IF	disint
	EI
	ret
;
gotodi:
	pop	psw
	lspd	regsp
	push	h
	lhld	regpc
	xthl
	ENDIF
	ret
;
;
	IF	extended
;
setrst:
	push	b
	push	d
	pushix
	lxi	h,rstsave
	lxi	d,rstsave+1
	lxi	b,9*4-1
	mvi	m,0ffh			; init save area
	ldir
	lxix	breaklist+1		; breakpoint list
	ldx	b,-1			; number of entries
	mov	a,b
	ora	a			; no breakpoints ?
	jrz	setrstex		; then go exit
setrst1:
	lxi	h,rstsave		; save area
	lxi	d,4			; entry length
setrstlp:
	mov	a,m			; save bank
	cmpx	2			; same as breakpoint bank ?
	jrz	setrstnext		; then get next break entry
	inr	a
	jrz	setrstenter		; enter jump if unused
	dad	d
	jr	setrstlp
;
setrstnext:
	inx	d
	dadx	d			; ix = ix + 5
	djnz	setrst1			; loop for all breakpoint entries
;
setrstex:
	popix
	pop	d
	pop	b
	ret
;
setrstenter:
	ldx	a,2			; breakpoint bank
	mov	m,a			; store in list
	call	selmem
	inx	h
	push	b			; save break count
	xchg
	lda	rstloc
	mov	l,a
	lxi	b,3		; save previous contents of restart location
	mov	h,b
	push	h
	push	b
	ldir
	pop	b
	pop	d
	lxi	h,jbreak	; insert jump to debugger at RST location
	ldir
	pop	b
	lxi	d,4
	jr	setrstnext
;
jbreak:
	jmp	ebreak
;
;
resetrst:
	lxi	h,rstsave
	lda	rstloc
	mov	e,a
	lxi	b,3
	mov	d,b
resetlp:
	mov	a,m
	cpi	0ffh
	jrz	resetex
	call	selmem
	inx	h
	push	d
	push	b
	ldir
	pop	b
	pop	d
	jr	resetlp
;
resetex:
	mvi	a,dfltbnk
	call	selmem
	ret
;
	ELSE
;
setrst:
	push	b
	push	d
	push	h
	lxi	d,rstsave
	lda	rstloc
	mov	l,a
	lxi	b,3		; save previous contents of restart location
	mov	h,b
	push	h
	push	b
	ldir
	pop	b
	pop	d
	lxi	h,jbreak	; insert jump to debugger at RST location
	ldir
	pop	h
	pop	d
	pop	b
	ret
;
jbreak:
	jmp	break
;
;
resetrst:
	lxi	h,rstsave
	lda	rstloc
	mov	e,a
	lxi	b,3
	mov	d,b
	ldir
	ret
;
	ENDIF
;
	IF	extended
;
;	ebreak:		Break entry for extended memory version.
;			restores bank before continuing.
;
ebreak:
	sspd	string
	lxi	sp,string+80
	push	psw
	mvi	a,dfltbnk
	call	selmem
	IF	mega
	sta	cbank		; mega bios returns previous bank in A
	ENDIF
	pop	psw
	lspd	string
	jmp	break
;
	ENDIF
;
;	debexit:	EXIT from debugger
;
debexit:
	call	nresetbk	; restore original memory contents
	IF	cpm3
	lxi	h,next-3
	ELSE
	lhld	next+1
	ENDIF
	shld	6		; restore BDOS entry
	lhld	biosloc
	shld	1		; restore BIOS entry
	mvi	a,0c3h		; restore JMP instruction
	sta	0		; in case it was overwritten
	sta	5
	IF	disint
	lda	regiff
	ani	1
	jrz	debexdi
	EI
	ENDIF
debexdi:
	pchl			; go to BIOS WBOOT entry
;
;
	IF	extended
;
;	currbank:	return current program (not EPROM) bank
;
;		entry:	-
;
;		exit:	A = bank
;
;		uses:	-
;
currbank:
	lda	cbank
	ret			; done.
;
;
;	xltbank:	return bank or default for "common"
;
;		entry:	A = bank or FF for current bank
;			HL = address
;
;		exit:	A = bank or FF if address is in a non-banked area.
;
;		uses:	-
;
xltbank:
	cpi	0ffh
	jrnz	xltb10
	lda	cbank
xltb10:
	push	h
	push	d
	ora	a
	lded	combase
	dsbc	d			; addr - common base
	pop	d
	pop	h
	rc				; ready if addr below common
	ori	0ffh			; set default for common
	ret
;
;
;	bankok:		set carry-flag if passed value is not a legal bank no.
;
;		entry:	A = bank number
;
;		exit:	carry set if not a legal bank
;
;		uses:	may use A, BC, DE
;
bankok:
	cpi	7fh		; default max legal bank number
	cmc
	ret
;
	ENDIF
;
restart	db	restartinst
rstloc	db	restartloc
;
;
	dseg
;
	IF	extended
rstsave	ds	9*4
	ELSE
rstsave	ds	3
	ENDIF
;
	IF	extended
;
combase	ds	2
;
pbank	ds	1
paddr	ds	2
peekbuf	ds	16
;
psbank	ds	1
psaddr	ds	2
;
	ENDIF
;
	end

