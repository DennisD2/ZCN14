	title	'System dependent routines for monitor'
;
;	Last Edited	85-04-27	Wagner
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
;	System dependent routines are collected in this module.
;
;	INITSYSTEM	is called upon initial entry into the monitor.
;			any hardware initialisation necessary only once
;			should be inserted here.
;			Also, this routine may initialise the default list,
;			dump, and assemble address (normally 0), and the
;			protection expression.
;
;	INITCIO		is called upon each re-entry into the monitor, i.e.
;			after a break.
;			it may be used to disable interrupts for the console
;			or to re-init console i/o.
;
;	WRCHAR		should write the character unedited to the console.
;	RDCHAR		should read a character from the console.
;	POLLCH		must return true if a character is available.
;			the character itself is not read by this routine.
;
;	JMACRO		may switch console input to a file.
;	KILLMAC		must revert input to the console.
;
;
;	READ		can read a file from the disk or via a communication
;			line. an offset or load address is passed.
;
;	WRITE		can write a file to the disk or via a communication 
;			line. a start and end address is passed.
;
;	FILE		may use the information in "string" to generate
;			a filename for read/write, or for any other purpose.
;
;	USERDEF		user defined command. jump to CMDERR if you do not
;			supply a debugger command here.
;
;
	cseg
;
	maclib	z80
	maclib	monopt
;
;
	public	next,biosloc
;
	public	initsystem,initcio
;
	public	rdchar,pollch
	public	wrchar
;
	public	jmacro,killmac
	public	userdef
;
	public	start,read,write,file
	IF	symbolic
	public	sfile
	public	readsymbol,symwrite,puthexbyte,putfilch
	ENDIF
;
;
	IF	symbolic
	extrn	syminit,rdsymname,defsymbol,wsymbols
	ENDIF
	extrn	regpc,string,regiff,regsp
	extrn	break
	extrn	listaddr,dumpaddr,asmaddr
	IF	hilo
	extrn	highval,lowval,maxval,topval
	ENDIF
	extrn	protexpbuf
	extrn	string,getch,testch,skipsep,skipsp,isdigit,iscontrol
	extrn	expression
	extrn	sgetch,stestch
	extrn	monent,cmderr,eocmd
	extrn	wrstr,crlf
	extrn	dishighlow
	extrn	inipeek
;
	IF	extended
	extrn	cbank,listbnk,dumpbnk,asmbnk
;
dfltbnk	equ	1		; default bank on program start
;
	ENDIF
;
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;
fcb	equ	05ch
fcb2	equ	06ch
;
;
;	RSX-Header
;
serial:
	db	0,0,0,0,0,0
start:
	jmp	cpmmon
next:
	jmp	0
;
prev:
	dw	0
remove:
	db	0ffh		; remove after execution
nonbank:
	db	0
	db	'MONIT   '
loader:
	db	0
	db	0,0
;
;
	jmp	warmboot	; boot-jump
biostab:
	jmp	warmboot	; exit through cleanup routine for warm boot
bioconst:
	ds	3
bioconin:
	ds	3
bioconout:
	ds	29*3		; remaining functions are not trapped
;
;
biosloc	ds	2		; real BIOS entry saved here
;
;
warmboot:
	lxi	h,0
	push	h		; simulate break at 0
	jmp	break
;
;
;
cpmmon:
	mov	a,c
	ora	a
	jrz	warmboot	; 0 is warm boot
;
	cpi	26		; set DMA ?
	jrnz	cpmmon10
	sded	dmaaddr		; save DMA address
	jmp	next
;
cpmmon10:
	cpi	45		; set error mode ?
	jrnz	cpmmon20
	mov	a,e
	sta	errmode
	jmp	next
;
cpmmon20:
	cpi	1		; console input ?
	jrnz	cpmmon30
	lda	trapinput
	ora	a
	jz	next		; pass on if no trap
	call	next
	lxi	h,trapchar
	cmp	m
	rnz			; return char if <> trap character
	mvi	c,1
	lxi	h,next
	push	h		; set retaddr to "next", so next time
	jmp	break		; program will get the character
;
cpmmon30:
	cpi	6
	jrnz	cpmmon40
	mov	a,e
	inr	a
	jrz	cpmconin
	inr	a
	jz	next
	inr	a
	jnz	next
cpmconin:
	lda	trapinput
	ora	a
	jz	next		; pass on if no trap
	call	next
	lxi	h,trapchar
	cmp	m
	rnz			; return char if <> trap character
	lxi	h,cpmconi1
	push	h		; set retaddr to "cpmconi1", so next time
	jmp	break		; program will get the character
;
cpmconi1:
	mvi	c,6
	IF	cpm3
	mvi	e,0fdh
	jmp	next
	ELSE
	mvi	e,0ffh
	call	next
	ora	a
	jrz	cpmconi1
	ret
	ENDIF
;
;
cpmmon40:
	cpi	60		; RSX call ?
	jnz	next		; pass on if not RSX
;
	lda	initcpm
	ora	a
	jnz	next		; pass on if initialised
	dcr	a
	sta	initcpm		; mark initialised
;
;	parameter block for initialisation:
;
;	db	0,0		; reserved
;	dw	protstr		; address of protection expression string
;
	xchg
	inx	h
	inx	h
	mov	e,m
	inx	h
	mov	d,m
	sded	pesave
;
	lxi	h,80h
	shld	dmaaddr
	xra	a
	sta	errmode
;
	lhld	1		; get BIOS entry
	shld	biosloc
	inx	h
	inx	h		; skip WBOOT
	inx	h
	shld	goconst+1	; save bios table entry for const
	lxi	d,bioconst
	lxi	b,3
	ldir
	shld	goconin+1	; save entry for conin
	lxi	b,3
	ldir
	shld	goconout+1	; save entry for conout
	lxi	b,29*3
	ldir
	lxi	h,biostab
	shld	1		; replace BIOS entry point
	lxi	h,conin
	shld	bioconin+1	; replace CONIN-entry in our BIOS trap table
	xra	a
	sta	trapinput	; mark no input trapping
	jmp	monent		; monitor main entry
;
;
;	replacement for BIOS-conin for user trap
;
conin:
	lda	trapinput
	ora	a
	jrnz	conin10
goconin:
	jmp	0
;
conin10:
	call	goconin
	push	h
	lxi	h,trapchar
	cmp	m
	pop	h
	rnz
	push	h
	lxi	h,goconin
	xthl				; put "goconin" as retaddr on stack
	jmp	break			; so on return prog will get char
;
;
;
;	initsystem:	initialise
;
;		entry:	-
;
;		exit:	-
;
;		uses:	may use all registers
;
initsystem:
	lxi	h,100h
	shld	listaddr
	shld	dumpaddr
	shld	asmaddr
	IF	extended
	mvi	a,dfltbnk
	sta	cbank
	sta	listbnk
	sta	dumpbnk
	sta	asmbnk
	ENDIF
	IF	hilo
	shld	lowval
	shld	highval
	shld	maxval
	ENDIF
	shld	regpc
	lxi	h,serial-1
	shld	topval
	lxi	d,warmboot
	mov	m,d
	dcx	h
	mov	m,e
	shld	regsp		; set sp to bottom, with retaddr = debexit
;
	lhld	pesave
	lxi	d,protexpbuf
init10:
	mov	a,m
	stax	d
	inx	h
	inx	d
	ora	a
	jrnz	init10
;
	lxi	h,100h
	lxi	d,101h
	lxi	b,serial-104h
	mov	m,a
	ldir			; clear memory
;
	call	inipeek
;
	IF	symbolic
	lxi	h,serial
	call	syminit
	lxi	h,fcb2
	lxi	d,symfcb
	lxi	b,32
	ldir
	ENDIF
;
	lda	fcb+1
	cpi	' '
	stc
	cnz	read
	IF	symbolic
	lda	symfcb+1
	cpi	' '
	rz
	lxi	h,symstr
	call	wrstr
	jmp	readsymdefault
;
symstr	db	'SYMBOLS',0dh,0ah,0
;
	ELSE
	ret
	ENDIF
;
;
;	initcio:	initialise console I/O
;
;		entry:	-
;
;		exit:	-
;
;		uses:	may use all registers
;
initcio:
	ret
;
;
;------------------------------------------------------------------------------
;
;
;	rdchar:		read char from console
;
;		entry:	-
;
;		exit:	A = character
;
;		uses:	-
;
rdchar:
	push	b
	push	d
	push	h
	lda	macactive
	ora	a
	jrz	rdchar1
	call	getmacch
	jrnc	rdcharex
	call	killmac
rdchar1:
	call	goconin
rdcharex:
	pop	h
	pop	d
	pop	b
	ret
;
;
;	pollch:		test if console input available
;			(should abort macro if active and char available)
;
;		entry:	-
;
;		exit:	A <> 0 if input available, flags set
;
;		uses:	-
;
pollch:
	push	b
	push	d
	push	h
goconst:
	call	0
;
	ora	a
	push	psw
	cnz	killmac
	pop	psw
	pop	h
	pop	d
	pop	b
	rz
	ori	0ffh
	ret
;
;
;	wrchar:		write char to console
;
;		entry:	A = character
;
;		exit:	-
;
;		uses:	-
;
wrchar:
	push	b
	push	d
	push	h
	push	psw
	mov	c,a
goconout:
	call	0
	pop	psw
	pop	h
	pop	d
	pop	b
	ret
;
;------------------------------------------------------------------------------
;
;	killmac:	revert input to console
;
;		entry:	IX points to input line
;
;		exit:	-
;
;		uses:	may use all registers
;
;
killmac:
	lxi	h,macactive
	mov	a,m
	ora	a
	rz
	mvi	m,0		; mark no longer active
	jmp	closerd		; close the file
;
;
;	jmacro:		activate macro-file
;
;		entry:	IX points to input line
;
;		exit:	-
;
;		uses:	may use all registers
;
jmacro:
	lxi	h,macpars
	lxi	d,macpars+1
	lxi	b,19
	mvi	m,0
	ldir			; clear parameter pointers
	call	killmac
	call	testch		; any character ?
	jz	cmderr		; error if not
	lxi	h,myfcb
	call	parsefn		; parse filename
	jc	cmderr		; error if parse filename found an error
	jrz	jmac50		; ok if no more parameters
;
	lxi	d,macparbuf
	lxi	b,80
	ldir			; copy buffer from position after filename
	lxi	h,macpars
	lxix	macparbuf
	call	skipsp		; skip spaces
	pushix
	pop	d		; pointer into DE
	mvi	b,10		; max params
	ldax	d
	cpi	','
	jrnz	jmac10
	inx	d		; skip first comma
;
jmac10:
	ldax	d
	inx	d
	ora	a
	jrz	jmac50
	cpi	' '
	jrz	jmac10		; skip spaces
	cpi	','
	jrnz	jmac20
	inx	h
	inx	h
	djnz	jmac10		; empty parameter
	jmp	cmderr
;
jmac20:
	dcx	d
	mov	m,e		; save start position
	inx	h
	mov	m,d
	inx	h
jmac30:
	ldax	d
	inx	d
	ora	a
	jrz	jmac50		; ready if end of string
	cpi	','
	jrnz	jmac30		; skip chars to next comma
	jr	jmac10
;
jmac50:
	call	openrd
	mvi	a,0ffh
	sta	macactive	; mark macro active
	lxi	h,0
	shld	parmp		; mark no parameter active
	ret			; ready
;
;
;	getmacch:	get one char from macro
;
getmacch:
	lhld	parmp		; parameter expansion pointer
	mov	a,h
	ora	l
	jrnz	getmacpar	; branch if inside parameter expansion
	call	getfilch
	rc			; ret with carry if EOF
;
getmacc1:
	cpi	'@'		; parameter ?
	jrz	getmacc2
	ora	a		; ret with char if not
	ret
;
getmacc2:
	call	getfilch	; get next char
	jc	cmderr		; error if single @
	cpi	'@'
	rz			; @@ becomes one @
	call	isdigit
	jc	cmderr		; error if not @n
	sui	'0'
	add	a		; * 2
	mov	e,a
	mvi	d,0
	lxi	h,macpars
	dad	d		; point to parameter pointer
	mov	e,m
	inx	h
	mov	d,m		; get parameter pointer
	xchg
	shld	parmp		; set parameter expansion pointer
	jr	getmacch	; go try again
;
getmacpar:
	mov	a,m
	ora	a
	jrz	getmacparend	; ready if end of string
	cpi	','
	jrz	getmacparend	; ready if comma
	inx	h
	shld	parmp
	ora	a		; else ret with char
	ret
;
;
getmacparend:
	lxi	h,0
	shld	parmp		; clear parameter pointer
	jr	getmacch	; and try again
;
;
;------------------------------------------------------------------------------
;
;	U:	User interrupt character
;
userdef:
	call	eocmd
	lxi	h,uintstr
	call	wrstr			; prompt
	call	rdchar			; get unedited character from console
	cpi	0dh
	jrz	userintdel		; CR means delete char
	sta	trapchar		; store char
	call	iscontrol
	jrc	userint1		; ok if not control
	push	psw
	mvi	a,'^'			; else display as ^c
	call	wrchar
	pop	psw
	adi	40h			; make it displayable
userint1:
	call	wrchar
	sta	trapinput		; mark char exists
	jmp	crlf
;
userintdel:
	xra	a
	sta	trapinput		; mark no trap
	jmp	crlf
;
;
uintstr	db	'Ch: ',0
;
;------------------------------------------------------------------------------
;
;	file:		set filename for read/write
;
;		entry:	"string" contains parameter text
;			(first char is 'F'-command)
;
;		exit:	-
;
;		uses:	may use all registers
;
file:
	lxix	string		; to start of string
	call	skipsep
	call	getch		; skip 'F'
	call	stestch
	cpi	' '
	jrz	file5		; ok if first char is ' '
	dcxix
	mvix	' ',0		; set first char to space
;
file5:
	lxi	h,51h
	lxi	d,52h
	lxi	b,5
	mvi	m,0
	ldir			; clear password pointers
;
	pushix			; save start position
	pushix			; again
	lxi	h,fcb
	call	parsefn
	popix			; string position
;	
	lxi	d,80h
	jrc	file10		; ready if error
	jrz	file10		; ready if EOS
;
	inx	h		; skip separator
	xchg			; into DE
;
file10:
	push	d
	lxi	h,fcb+16	; password ?
	mov	a,m
	cpi	' '
	jrz	file20
;
	call	pwcount		; get password pointer/count field
;
	mov	a,b
	sta	52h
	adi	81h
	sta	51h		; set addr
	mov	a,c
	sta	53h		; set length
;
file20:
	popix			; string start into IX
	pushix			; save
	lxi	h,0
	shld	80h
	lxi	h,fcb2
	call	parsefn
	popix
	lxi	h,fcb2+16	; password ?
	mov	a,m
	cpi	' '
	jrz	file30
;
	call	pwcount		; get password pointer/count field
;
	lda	52h
	add	b
	adi	81h
	sta	54h		; set addr
	mov	a,c
	sta	56h		; set length
;
file30:
	xra	a
	sta	52h
	lxi	h,0
	shld	7ch
	shld	7eh
	popix			; string start
	lxi	h,81h
	mvi	b,0
file31:
	call	sgetch
	mov	m,a
	jrz	file40
	inx	h
	inr	b
	jr	file31
;
file40:
	mov	a,b
	sta	80h		; set command line length
;
	ret
;
;
	IF	symbolic
;
;	sfile:		set filename for symbol read/write
;
;		entry:	"string" contains parameter text
;
;		exit:	-
;
;		uses:	may use all registers
;
sfile:
	lxi	h,symfcb
	call	parsefn
	jc	cmderr
	ret
;
	ENDIF
;
;
pwcount:
	lxi	b,0
pwcount5:
	call	sgetch
	jrz	pwcount10
	cpi	';'
	jrz	pwcount10
	inr	b
	jr	pwcount5
;
pwcount10:
	mov	a,m
	ora	a
	rz
	cpi	' '
	rz
	inx	h
	inr	c
	jr	pwcount10
;
;
;	parsefn:	scan input line for filename
;
;		entry:	IX = input line pointer
;			HL = fcb address
;
;		exit:	HL = pointer to next char if not error or eol
;			carry set if error
;			zero set if end of line
;
;		uses:	all regs
;
;
parsefn:
	IF	cpm3
	sixd	pfcbin
	shld	pfcbout
	mvi	c,152
	lxi	d,pfcbin
	call	next
	ELSE
	call	scanfn
	ENDIF
	mov	a,l
	ora	h
	rz
	inx	h
	mov	a,h
	ora	l
	stc
	rz
	dcx	h
	ora	a
	ret
;
;
	IF	NOT cpm3
;
;	scanfn:		scan input line for filename
;
;		entry:	IX = input line pointer
;			HL = fcb address
;
;		exit:	HL = next input line address if more follows
;			HL = 0 if end of input line reached
;			HL = 0ffffh if error occurred
;
;		uses:	all regs
;
scanfn:
	push	h
	mvi	m,0		; init drive to 0
	inx	h
	mov	d,h
	mov	e,l
	inx	d
	mvi	m,' '
	lxi	b,11
	ldir			; init fn/ft to spaces
	mvi	m,0
	lxi	b,4
	ldir			; init ex/s1/s2/rc to 0
	mvi	m,' '
	lxi	b,8
	ldir			; init password field to spaces
	mvi	m,0
	lxi	b,11
	ldir			; init remainder of fcb to 0
	pop	h
	push	h
	call	scanskip
	call	isdelim
	jrnc	scanfnret	; ret with next char if delimiter
	call	sgetch		; get the char
	push	psw
	call	stestch		; check next char
	cpi	':'
	jrnz	scanfn10	; branch if not a drive specification
	pop	psw
	cpi	'A'
	jrc	scanfnreterr	; ret error if not A..P
	cpi	'P'+1
	jrnc	scanfnreterr
	sui	'A'-1
	mov	m,a		; set drive spec
	call	sgetch		; skip ':'
	call	stestch		; get next char
	call	isdelim
	jrnc	scanfnret	; ret if drive spec only
	call	sgetch		; get the char
	push	psw
;
scanfn10:
	pop	psw
	inx	h
	mov	m,a
	inx	h
	mvi	b,8		; max length + 1
scanfn20:
	call	stestch
	cpi	'.'
	jrz	scanfn40	; branch if extent
	call	isdelim
	jrnc	scanfnret	; ready if delimiter
	dcr	b
	jrz	scanfnreterr	; error if fn too long
	call	sgetch
	cpi	'*'
	jrz	scanfn30	; '*' is translated to ???...
	mov	m,a
	inx	h
	jr	scanfn20
;
scanfn30:
	mvi	m,'?'
	inx	h
	djnz	scanfn30
	mvi	b,1
	jr	scanfn20
;
;
scanfn40:
	pop	h
	push	h
	lxi	b,9
	dad	b		; point to extent
	mvi	b,4		; max length + 1
	call	sgetch		; skip '.'
;
scanfn50:
	call	stestch
	call	isdelim
	jrnc	scanfnret	; ready if delimiter
	dcr	b
	jrz	scanfnreterr	; error if extent too long
	call	sgetch
	cpi	'*'
	jrz	scanfn60
	mov	m,a
	inx	h
	jr	scanfn50
;
scanfn60:
	mvi	m,'?'
	inx	h
	djnz	scanfn60
	mvi	b,1
	jr	scanfn50
;
;
scanfnret:
	pop	h
	call	scanskip
	jrz	scanfnret0	; return 0 if end of line
	pushix
	pop	h
	ret
;
scanfnreterr:
	pop	h
	lxi	h,0ffffh
	ret
;
scanfnret0:
	lxi	h,0
	ret
;
;
scanskip:
	ldx	a,0
	ora	a
	rz
	cpi	' '
	jnz	stestch
	inxix
	jr	scanskip
;
isdelim:
	ora	a
	rz
	push	h
	push	b
	lxi	h,delimtab
	lxi	b,delimlen
	ccir
	pop	b
	pop	h
	rz			; ret zero if delimiter
	stc
	ret			; else ret with carry set
;
delimtab:
	db	' ;=<>.:,|[]'
;
delimlen	equ	$-delimtab
;
	ENDIF
;
;
;------------------------------------------------------------------------------
;
	IF	fileops
;
;
;	read:		read a file
;
;		entry:	A/HL = offset (or load address)
;			Carry set if no offset given
;
read:
	jrnc	read1
	lxi	h,0
read1:
	shld	rwoffset	; save offset
	lxi	h,fcb
	call	rwinit
	call	openrd
	IF	cpm3
	lda	myfcb		; drive id
	sta	50h		; set as program load drive
	ENDIF
	call	ishexfile
	jz	rdhexfile
;
	xra	a
	sta	myfcb+32	; clear cr to read first record again
	call	erroff
;
	IF	cpm3
	lda	rwbuf		; get first byte of file
	cpi	0c9h		; RET instruction ?
	jrnz	rdcomfile	; normal COM-file if not
	call	iscomfile	; .COM-Extension ?
	jrnz	rdcomfile	; don't process RSX if not
;
	lxi	h,rsxstr
	call	wrstr
	lhld	rwoffset
	lxi	d,100h
	dad	d
	shld	myfcb+33	; set load address
	lxi	d,myfcb
	mvi	c,59		; load overlay function
	call	next		; load program & attached RSX
	ora	a
	jnz	rwerror
	IF	hilo
	lhld	topval
	shld	maxval
	lhld	6
	shld	highval
	lded	regsp
	dsbc	d		; RSX-entry-address - current SP
	jrnc	rsxldok		; ok if SP below RSX
	lhld	6
	mov	a,l
	ani	0f0h
	mov	l,a
	xra	a
	dcx	h
	mov	m,a		; set stack to 0
	dcx	h
	mov	m,a
	shld	regsp		; else set SP at RSX entry
	ENDIF
rsxldok:
	call	closerd
	IF	hilo
	jmp	dishighlow
	ELSE
	ret
	ENDIF
;
rsxstr	db	'Attached RSX',0dh,0ah,0
;
	ENDIF
;
rdcomfile:
	lhld	rwoffset
	lxi	d,100h
	dad	d
	push	h
	lxi	d,80h
	ora	a
	dsbc	d
	jc	rwerror		; cant read below 80h
	pop	h
;
rdcomloop:
	push	d		; save 80h
	push	h		; save current DMA
	xchg			; DMA into HL
	dad	d		; add 80 again for last read addr
	IF	hilo
	lbcd	topval		; max read addr
	ELSE
	lxi	b,serial-1	; maximum read addr
	ENDIF
	inx	b		; plus one to get carry
	ora	a
	dsbc	b
	jnc	rwerror		; error if read would overwrite us
	mvi	c,26
	call	next		; set dma
	lxi	d,myfcb
	mvi	c,20
	call	next		; read file
	pop	h
	pop	d
	ora	a
	jrnz	rdready
	dad	d		; increase dma addr
	jr	rdcomloop	; continue if no error
;
rdready:
	IF	hilo
	dcx	h
	shld	highval
	xchg
	lhld	maxval
	ora	a
	dsbc	d
	jrnc	rdready1
	sded	maxval
	ENDIF
rdready1:
	push	psw
	call	closerd
	IF	hilo
	call	dishighlow
	ENDIF
	pop	psw
	cpi	1
	jnz	cmderr		; error if not eof
	ret
;
;
;	read intel hex format
;
rdhexfile:
	lxi	h,0
	shld	tmphigh
;
rdhexloop:
	call	getfilch
	jrc	rdhexready
	cpi	':'
	jrnz	rdhexloop
;
	call	gethexbyte
	mov	b,a		; length
	mov	c,a		; init checksum
;
	call	gethexbyte
	mov	d,a
	call	gethexbyte
	mov	e,a		; address
	call	gethexbyte	; type
	ora	a
	jrz	rdhexdata
	dcr	a
	jrz	rdhexready1	; ready on end of file marker
	cpi	2		; 03 = start addr
	jnz	cmderr
	xchg
	shld	regpc
	shld	listaddr
	call	rdchecksum
	jmp	rdhexloop
;
rdhexready1:
	call	rdchecksum
;
rdhexready:
	IF	hilo
	lhld	tmphigh
	dcx	h
	shld	highval
	xchg
	lhld	maxval
	ora	a
	dsbc	d
	jrnc	rdhexready2
	sded	maxval
	ENDIF
rdhexready2:
	call	closerd
	IF	hilo
	jmp	dishighlow
	ELSE
	ret
	ENDIF
;
;
rdhexdata:
	mov	a,b
	ora	a
	jrz	rdhexloop
	lhld	rwoffset
	dad	d
	push	h
	ora	a
	lxi	d,80h
	dsbc	d
	jc	cmderr
	pop	h
	push	h		; current address
	mov	e,b		; DE = length (D is still = 0)
	dad	d		; top addr for this record
	IF	hilo
	lded	topval		; max allowed addr
	ELSE
	lxi	d,serial-1
	ENDIF
	inx	d		; plus one for carry
	ora	a
	dsbc	d
	jnc	cmderr		; error if read above top
	pop	h
;
rdhexdatloop:
	call	gethexbyte
	mov	m,a
	inx	h
	djnz	rdhexdatloop
rdhexdend:
	call	rdchecksum
	xchg
	lhld	tmphigh
	ora	a
	dsbc	d
	jnc	rdhexloop
	sded	tmphigh
	jmp	rdhexloop
;
;
gethexbyte:
	push	b
	push	d
	push	h
	call	getfilch
	jc	cmderr
	call	aschex
	rlc
	rlc
	rlc
	rlc
	push	psw
	call	getfilch
	jc	cmderr
	call	aschex
	mov	c,a
	pop	psw
	ora	c
	pop	h
	pop	d
	pop	b
	push	psw
	add	c
	mov	c,a
	pop	psw
	ret
;
;
rdchecksum:
	mov	b,c
	call	gethexbyte
	neg
	cmp	b
	jnz	cmderr
	ret
;
;
aschex:
	sui	'0'
	jc	cmderr
	cpi	10
	rc
	sui	'A'-'0'
	jc	cmderr
	adi	10
	cpi	10h
	rc
	jmp	cmderr
;
;------------------------------------------------------------------------------
;
rwrestore:
	lded	dmaaddr
	mvi	c,26
	call	next		; restore user DMA
	IF	cpm3
	lda	errmode
	mvi	c,45
	call	next		; restore error mode
	ENDIF
	ret			; ready
;
rwerror:
	call	rwrestore
	jmp	cmderr
;
erroff:
	IF	cpm3
	mvi	e,0feh
	mvi	c,45
	jmp	next		; set error mode
	ELSE
	ret
	ENDIF
;
;
rwinit:
	lxi	d,myfcb
	lxi	b,14
	ldir			; copy fcb
	mov	h,d
	mov	l,e
	inx	d
	mvi	m,0
	lxi	b,21
	ldir			; fill fcb with 0
	ret
;
iscomfile:
	lxi	h,comstr
	jr	ishexcom
;
ishexfile:
	lxi	h,hexstr
ishexcom:
	lxi	d,myfcb+9	; extension
	mvi	b,3
ishexlp:
	ldax	d
	ani	7fh
	cmp	m
	rnz
	inx	d
	inx	h
	djnz	ishexlp
	xra	a
	ret
;
hexstr	db	'HEX'
comstr	db	'COM'
;
;------------------------------------------------------------------------------
;
;	write:		write file
;
;		entry:	A/HL = first address
;			DE = last address
;
write:
	lda	fcb+1
	cpi	' '
	jz	cmderr
	push	d		; save end
	push	h		; save start
	ora	a
	dsbc	d
	jnc	cmderr		; error	if end <= start
	lxi	h,fcb
	call	rwinit
	call	openwr
	call	ishexfile
	jz	wrhexfile
;
wrcomfile:
	call	eocmd
	call	erroff
	pop	d		; start
;
wrcomloop:
	push	d
	mvi	c,26
	call	next		; set dma
	lxi	d,myfcb
	mvi	c,21
	call	next		; write file
	pop	h
	ora	a
	jnz	rwerror
	lxi	d,80h
	dad	d		; increase dma addr
	pop	d		; get end
	push	d
	xchg
	ora	a
	dsbc	d		; end - current
	jrnc	wrcomloop	; continue if current < end
	pop	d		; discard end
;
	lxi	d,myfcb
	mvi	c,16
	call	next		; close
	inr	a
	jz	rwerror
	jmp	rwrestore
;
;
wrhexfile:
	call	expression
	jrnc	wrhexfil10
	lxi	h,0
wrhexfil10:
	shld	rwoffset
	call	eocmd
	pop	h		; start
wrhexloop:
	mvi	b,16
	xchg
	lhld	rwoffset
	dad	d
	push	d
	call	starthexrec
	pop	h
wrhexl1:
	mov	a,m
	call	puthexbyte
	inx	h
	djnz	wrhexl1
	push	h
	call	endhexrec
	pop	d		; curr
	pop	h		; end
	push	h
	ora	a
	dsbc	d		; end - curr
	xchg
	jrnc	wrhexloop
;
	pop	d
	mvi	b,0
	lxi	h,0
	call	starthexrec
	call	endhexrec
	jmp	closewr
;
;
puthexbyte:
	push	psw
	add	c
	mov	c,a
	pop	psw
	push	b
	push	d
	push	h
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	puthexdig
	pop	psw
	call	puthexdig
	pop	h
	pop	d
	pop	b
	ret
;
puthexdig:
	ani	0fh
	adi	'0'
	cpi	'9'+1
	jc	putfilch
	adi	'A'-'0'-10
	jmp	putfilch
;
;
starthexrec:
	push	h
	mvi	a,':'
	push	b
	call	putfilch
	pop	b
	mvi	c,0
	mov	a,b
	call	puthexbyte
	pop	h
	mov	a,h
	call	puthexbyte
	mov	a,l
	call	puthexbyte
	mov	a,b
	ora	a
	mvi	a,0
	jnz	puthexbyte
	inr	a
	jmp	puthexbyte
;
;
endhexrec:
	push	h
	mov	a,c
	neg
	call	puthexbyte
	mvi	a,0dh
	call	putfilch
	mvi	a,0ah
	call	putfilch
	pop	h
	ret
;
;
;------------------------------------------------------------------------------
;
;	openrd:		open file (fcb = myfcb) for reading
;
openrd:
	call	killmac
	call	erroff		; set error mode
	lxi	d,myfcb
	mvi	c,15
	call	next		; open the file
	inr	a
	jz	rwerror		; error if not opened
	xra	a
	sta	myfcb+32	; clear cr-field
	call	getfilrec	; read
	jnz	cmderr		; read already did the rwrestore
	ret
;
;
;	getfilrec:	read one record from the file
;
;		exit:	A = read error code (<> 0 if error)
;
getfilrec:
	xra	a
	sta	rwptr
	call	erroff		; set error mode
	lxi	d,rwbuf
	mvi	c,26
	call	next		; set dma
	lxi	d,myfcb
	mvi	c,20
	call	next		; read
	push	psw
	call	rwrestore
	pop	psw
	ora	a
	ret			; ret with error code from read
;
;
;	getfilch:	get one byte from the file
;
;		exit:	A = char
;			Carry set if EOF
;
getfilch:
	lda	rwptr
	cpi	128
	jrnz	getfilch1
	call	getfilrec
	stc
	rnz
getfilch1:
	lxi	h,rwptr
	mov	e,m
	inr	m
	mvi	d,0
	lxi	h,rwbuf
	dad	d
	mov	a,m
	cpi	1ah
	stc
	rz
	ora	a
	ret
;
;
;	closerd:	close read file
;
closerd:
	call	erroff
	lxi	d,myfcb
	mvi	c,16
	call	next
	jmp	rwrestore
;
;
;	openwr:		open file (fcb = myfcb) for writing
;
openwr:
	call	killmac
	call	erroff		; set error mode
	lxi	d,myfcb
	mvi	c,19
	call	next		; delete file
	mov	a,h
	ora	a
	jnz	rwerror		; abort if physical error
	lxi	d,myfcb
	mvi	c,22		; make file
	call	next
	inr	a
	jz	rwerror		; error if not made
	xra	a
	sta	myfcb+32	; clear CR-field
	sta	rwptr
	call	rwrestore
	ret
;
;
;	putfilrec:	write one record to the file
;
putfilrec:
	xra	a
	sta	rwptr
	call	erroff		; set error mode
	lxi	d,rwbuf
	mvi	c,26
	call	next		; set dma
	lxi	d,myfcb
	mvi	c,21
	call	next		; write
	push	psw
	call	rwrestore
	pop	psw
	ora	a
	jnz	cmderr		; abort on error
	ret
;
;
;	putfilch:	put one byte to the file
;
;		entry:	A = char
;
putfilch:
	push	psw
	lda	rwptr
	cpi	128
	jrnz	putfilch1
	call	putfilrec
putfilch1:
	pop	psw
	lxi	h,rwptr
	mov	e,m
	inr	m
	mvi	d,0
	lxi	h,rwbuf
	dad	d
	mov	m,a
	ret
;
;
;	closewr:	close the file
;
closewr:
	lda	rwptr
	cpi	128
	jrz	closewr1
	mvi	a,01ah
	call	putfilch		; fill  record with 1a
	jr	closewr
;
closewr1:
	call	putfilrec		; write last record
	call	erroff
	lxi	d,myfcb
	mvi	c,16			; close
	call	next
	inr	a
	jz	rwerror
	jmp	rwrestore
;
;
	IF	symbolic
;
;	readsymbol:	read symbols from file
;
readsymdefault:
	lxi	h,0
	shld	rwoffset
	jr	readsym10
;
readsymbol:
	jrnc	readsym01
	lxi	h,0
readsym01:
	shld	rwoffset
	call	eocmd
	lda	symfcb+1
	cpi	' '
	jz	cmderr
readsym10:
	lxi	h,symfcb
	call	rwinit
	call	openrd
readsymline:
	lxix	string
	mvi	b,80		; max input line length
readsymlin10:
	push	b
	call	getfilch
	pop	b
	jrc	readsymlin80
	cpi	0dh
	jrz	readsymlin70
	cpi	0ah
	jrz	readsymlin10
	cpi	09h
	jrnz	readsymlin20
	mvi	a,' '
readsymlin20:
	cpi	20h
	jc	rwerror
	stx	a,0
	inxix
	djnz	readsymlin10
	jmp	rwerror
;
readsymlin70:
	mov	a,b
	cpi	80
	jrz	readsymline
	call	evalsym
	jr	readsymline
;
readsymlin80:
	mov	a,b
	cpi	80
	cnz	evalsym
	call	closerd
	jmp	dishighlow
;
;
evalsym:
	mvix	0,0
	lxix	string
evalsym10:
	call	skipsp
	rz
	call	expression
	jc	cmderr
	lded	rwoffset
	dad	d
	push	h
	call	rdsymname
	jc	cmderr
	pop	d
	call	defsymbol
	jr	evalsym10
;
;
;	symwrite:	write symbols to file
;
symwrite:
	lda	symfcb+1
	cpi	' '
	jz	cmderr
	call	eocmd
	lxi	h,symfcb
	call	rwinit
	call	openwr
	call	wsymbols
	jmp	closewr
;
;
	ENDIF	; symbolic
;
	ENDIF	; fileops
;
;------------------------------------------------------------------------------
;
	dseg
;
initcpm		db	0
dmaaddr		ds	2
errmode		ds	1
;
;
trapinput	ds	1
trapchar	ds	1
macactive	ds	1
parmp		ds	2
macparbuf	ds	80
macpars		ds	20
;
myfcb		ds	36
rwbuf		ds	128
rwptr		ds	1
;
symfcb		ds	36
;
pfcbin		ds	2
pfcbout		ds	2
;
rwoffset	equ	pfcbin
pesave		equ	pfcbout
tmphigh		equ	pfcbout
;
	end
