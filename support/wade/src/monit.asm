	title	'Monitor Main Module'
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
	maclib	z80
	maclib	monopt
;
	public	monent,monmain,monitor,cmderr,eocmd
	public	stack,listaddr,asmaddr,dumpaddr,variables
;
	IF	hilo
	public	highval,lowval,maxval,topval
	ENDIF
	IF	extended
	public	listbnk,dumpbnk,asmbnk
	ENDIF
;
	public	tracecount,tracejp,tracenl,traceexp,traceptr,trcallopt
	public	bkexpbuf,protexpbuf
	public	prompt
;
	extrn	initsystem
;
	IF	symbolic
	extrn	rdsymname,defsymbol,killsymbol,dissymbols,wrsymbol
	extrn	symstart
	IF	fileops
	extrn	symtop,readsym,symwrite,rsvsym
	extrn	sfile
	ENDIF
	ENDIF
;
	extrn	wraddr,wrchar
;
	IF	extended
	extrn	xltbank,peek,peeks,poke,paddr,pbank,psaddr,psbank,peekbuf,cbank
	ENDIF
;
	extrn	wrhex,wrhexdig,wrword,space,space2,crlf,wrdec,wrbit,wrstr
	extrn	readstring,expression,skipsep,bytestring,rdregister
	extrn	mexpression,sexpression
	extrn	getch,testch,isletter,isdigit,isspecial,iscontrol
	extrn	string
;
	extrn	userdef
	extrn	disasm,assemble,analop
	extrn	initbreak,display,disalt,disyvars,unbreak,dotrace
;
	IF	hilo
	extrn	dishighlow
	ENDIF
;
	IF	fileops
	extrn	read,write,file,jmacro,killmac
	ENDIF
;
	extrn	deletebk,definebk,numbreaks,breaklist,addbk
;
	extrn	regi,regiff,regbc,regpc,altbc
;
;
;	This is the main entry to the monitor.
;	Variables and registers are initialised, then INITSYSTEM is called
;	for system dependent initialisations.
;
monent:
	lxi	sp,stack
	lxi	h,varstart
	lxi	d,varstart+1
	lxi	b,varspace-1
	mvi	m,0
	ldir			; init all defaults and variables to 0
	call	initbreak	; init break-variables
	call	initsystem	; system dependent initialisation
	call	crlf
;
;
;	MONITOR is the entry jumped to on a break.
;
monitor:
	IF	extended
	mvi	a,0ffh
	sta	listbnk
	sta	dumpbnk
	sta	asmbnk
	ENDIF
;
;
;	MONMAIN is the main program loop.
;	It is also the entry jumped to by CMDERR
;
monmain:
	xra	a
	sta	tracecount	; in case trace was aborted in CRLF
	lxi	sp,stack	; re-init stack
;
	call	resettmpbk
;
	mvi	a,':'
prompt	equ	$-1
	call	wrchar		; prompt
	call	readstring	; get command
	call	getch
	mvi	b,0ffh
	jrnz	monmain1	; ok if not empty
	lda	dumpword
	mov	b,a
	lda	lastop		; use last command as default
monmain1:
	sta	lastop		; remember last command
	lxi	h,dumpword
	mov	m,b
moncmd:
	lxi	h,commands
	call	tabsel		; select routine
	jr	monmain		; loop
;
;
tabsel:
	call	isletter	; letter ?
	jrc	cmderr		; no command if not
	sui	'A'
	add	a		; *2
	mov	e,a
	mvi	d,0
	lxi	h,commands
	dad	d		; point to command handler
	mov	e,m
	inx	h
	mov	d,m		; command handler address
	xchg			; into hl
	call	skipsep		; prepare access to next char
	pchl			; enter routine
;
;
;	eocmd:		check for end of command, abort if not at end
;
eocmd:
	push	psw
	call	skipsep
	jrnz	cmderr
	pop	psw
	ret
;
;
;	cmderr:		issue error message, go to main loop
;
cmderr:
	mvi	a,'?'		; issue error message
	call	wrchar
	call	wrchar		; write ??
	call	crlf
	IF	fileops
	call	killmac
	ENDIF
	jr	monmain		; loop
;
;
;	command handler table
;
commands:
	dw	asmop		; A
	dw	breakset	; B
	dw	calltrace	; C
	dw	dump		; D
	IF	fileops
	dw	exec		; E
	dw	file		; F
	ELSE
	dw	cmderr
	dw	cmderr
	ENDIF
	dw	go		; G
	dw	hexcalc		; H
	dw	input		; I
	IF	fileops
	dw	jmacro		; J
	dw	killmac		; K
	ELSE
	dw	cmderr
	dw	cmderr
	ENDIF
	dw	list		; L
	dw	move		; M
	IF	symbolic
	dw	namedef		; N
	ELSE
	dw	cmderr		; N (undef)
	ENDIF
	dw	output		; O
	dw	protect		; P
	dw	query		; Q
	IF	fileops
	dw	fread		; R
	ELSE
	dw	cmderr
	ENDIF
	dw	substit		; S
	dw	trace		; T
	dw	userdef		; U
	dw	verify		; V
	IF	fileops
	dw	fwrite		; W
	ELSE
	dw	cmderr
	ENDIF
	dw	where		; X
	dw	yvar		; Y
	dw	zap		; Z
;
;------------------------------------------------------------------------------
;
;	A:	Assemble
;
asmop:
	call	expression
	jrnc	asmop10			; ok if expression
	call	eocmd
	lhld	asmaddr			; else use defaults
	jr	asmloop
;
asmop10:
	IF	extended
	sta	asmbnk
	ENDIF
	call	eocmd
asmloop:
	shld	asmaddr			; save as default
	push	h
	IF	extended
	lda	asmbnk
	ENDIF
	IF	symbolic
	mvi	b,0
	ELSE
	mvi	b,0ffh
	ENDIF
	call	disasm			; disassemble
	call	readstring		; get input
	jrz	asm10			; next if null input
	pop	h
	cpi	'.'
	rz				; exit if dot
	push	h			; current address
	IF	extended
	lda	asmbnk
	ENDIF
	call	assemble		; assemble
	IF	extended
	call	poke			; store back
	ENDIF
asm10:
	pop	h
	call	analop			; analyse again to get length
	jr	asmloop			; and loop
;
;
;------------------------------------------------------------------------------
;
;	B:	set breakpoint
;
breakset:
	jrz	breaklst	; no parameter means list
	cpi	'X'
	jz	breakdel	; X means delete breakpoint
	cpi	'I'
	jrnz	breaks1		; I means condition
	call	getch		; skip I
	call	clrbkcond	; clear old condition flags
	call	copyexp		; copy expression
	mvi	c,0ffh		; mark conditional
	jr	breaks2
;
breaks1:
	mvi	c,0		; mark unconditional
breaks2:
	push	b
	call	sexpression	; get breakpoint addr
	pop	b
	jc	cmderr		; error if something else
;
breakslp:
	push	b
	call	definebk	; define breakpoint
	call	sexpression	; check for another
	pop	b
	jc	eocmd		; ready if end
	jr	breakslp
;
;
breaklst:			; list breakpoints
	lda	numbreaks
	ora	a
	rz			; ready if none
	mov	b,a		; B = number of entries
	lxiy	breaklist+1	; IY = break def pointer
	lxi	d,5		; DE = entry length
	mvi	c,0		; C = marker: list condition if nonzero
	IF	symbolic
	mvi	h,3		; H = counter for entries per line
	ELSE
	mvi	h,4
	ENDIF
	mov	l,c		; L = marker: at start of line if zero
breakll:
	push	h
	ldy	l,0		; HL = break addr
	ldy	h,1
	IF	extended
	ldy	a,2		; bank
	ENDIF
	call	wraddr		; write breakpoint address
	ldy	a,3		; conditional flag
	ora	a
	jrz	breakll1
	mov	c,a		; mark condition occurred
	push	h
	lxi	h,bkcnstr
	call	wrstr		; mark as conditional
	pop	h
breakll1:
	IF	symbolic
	call	space
	mvi	a,'.'
	pushiy
	push	d
	push	b
	call	wrsymbol
	pop	b
	pop	d
	popiy
	ENDIF
	call	space2
	dady	d		; next entry
	pop	h		; restore entry counter
	inr	l
	dcr	h
	jrnz	breakll2	; jump if not end of line
	call	crlf
	IF	symbolic
	mvi	h,3
	ELSE
	mvi	h,4
	ENDIF
	mvi	l,0
breakll2:
	djnz	breakll
;
breaklsti:
	mov	a,l
	ora	a
	cnz	crlf		; CRLF if not at start of line
	mov	a,c
	ora	a		; conditional breakpoint found ?
	rz			; ready if not
	lxi	h,bkifstr
	call	wrstr		; else display condition
	lxi	h,bkexpbuf
	call	wrstr
	jmp	crlf
;
;
breakdel:
	call	getch		; skip 'X'
	call	testch
	sui	'I'		; delete condition only ?
	jrz	clrbkcond
	call	sexpression	; get breakpoint addr
	jrc	breakdelall	; delete all breakpoints if no address
;
breakdellp:
	call	deletebk
	call	sexpression	; check if another one to delete
	jc	eocmd		; ready if not
	jr	breakdellp
;
breakdelall:
	call	eocmd
	xra	a		; delete all breakpoints
	sta	numbreaks
	sta	breaklist
	ret
;
;
clrbkcond:			; clear conditional flag in all breakpoints
	lda	numbreaks
	ora	a
	rz
	mov	b,a
	lxi	h,breaklist+4	; first condition field
	lxi	d,5
clrbklp:
	mvi	m,0
	dad	d
	djnz	clrbklp
	ret
;
;
;	copy expression into save area
;
copyexp:
	call	skipsep
	lxi	d,bkexpbuf		; destination
	pushix
	pop	h			; current line pointer
copyexlp:
	mov	a,m			; copy up to ';'
	ora	a
	jz	cmderr			; error if end of line
	cpi	';'
	jrz	copyex10		; ready if ;
	stax	d			; store char
	inx	h
	inx	d
	jr	copyexlp
;
copyex10:
	xra	a
	stax	d			; terminate
	call	mexpression		; evaluate once to trap errors
	jc	cmderr
	call	getch
	cpi	';'
	jnz	cmderr			; error if something after expression
	ret
;
;
bkifstr	db	'If: ',0
bkcnstr	db	'(If)',0
;
;------------------------------------------------------------------------------
;
;	D:	Dump
;
dump:
	cpi	'W'
	jrnz	dump05
	call	getch
	call	skipsep
	xra	a
	jr	dump06
dump05:
	lda	dumpword
	ora	a
dump06:
	sta	dumpword
	push	psw
	call	sexpression	; from
	jrnc	dump10
	lded	dumpaddr	; use default if no from address
	jr	dump15
;
dump10:
	IF	extended
	sta	dumpbnk
	ENDIF
	push	h
	call	sexpression	; end address
	pop	d
	jrnc	dump20		; ok if specified
;
dump15:
	lxi	h,7fh		; default end address = from + 7fh
	dad	d
	jrnc	dump20		; ok if no wraparound to zero
	lxi	h,0ffffh

;
dump20:
	call	eocmd
	xchg			; HL = from, DE = end
;
;	write dump header line
;
	mvi	b,7
	IF	extended
	lda	dumpbnk
	cpi	0ffh		; default bank ?
	jrz	dumpspac	; then 7 spaces
	push	h
	lxi	h,cbank
	cmp	m		; same as current bank ?
	pop	h
	jrz	dumpspac	; then 7 spaces
	mvi	b,10		; else three spaces more for 'hh:'
	ENDIF
dumpspac:
	call	space
	djnz	dumpspac		; write spaces
;
	pop	psw		; W-option ?
	mov	a,l			; low byte of addr
	mvi	b,8
	jrz	dumpwhdr
	mvi	b,16
;
dumphdr:
	push	psw
	call	wrhexdig		; write lower nibble
	call	space2
	mov	a,b
	cpi	9
	cz	space			; one space after 8 digits
	pop	psw
	inr	a
	djnz	dumphdr
	call	crlf
;
;	write dump
;
dumploop:
	IF	extended
	lda	dumpbnk
	ENDIF
	call	dumpline		; dump a line
	shld	dumpaddr		; store next addr as default
;
	mov	a,d			; end
	inr	a
	cmp	h			; hi(curr) = hi(end) + 1 ?
	rz				; then wraparound, stop dump
	ora	a
	push	d			; end
	xchg
	dsbc	d			; end - current
	xchg
	pop	d			; end
	jrnc	dumploop		; again if end >= current
	ret
;
;
dumpwhdr:
	push	psw
	inr	a
	call	wrhexdig		; write lower nibble
	call	space
	pop	psw
	push	psw
	call	wrhexdig
	call	space2
	call	space
	pop	psw
	inr	a
	inr	a
	djnz	dumpwhdr
	call	crlf
;
;	write dump
;
dumpwloop:
	IF	extended
	lda	dumpbnk
	ENDIF
	call	dumpwline		; dump a line
	shld	dumpaddr		; store next addr as default
;
	ora	a
	push	d
	xchg
	dsbc	d			; end - current
	xchg
	pop	d
	jrnc	dumpwloop		; again if end >= current
	ret
;
;
;	dumpline:	dump one line
;
;		entry:	A/HL = address
;
;		exit:	HL = HL + 16
;
dumpline:
	push	b
	IF	extended
	push	h
	call	peek
	ENDIF
	call	wraddr			; show address
	call	space2
;
	mvi	b,16
	IF	extended
	lxi	h,peekbuf
	ELSE
	push	h
	ENDIF
dumplinlp:
	mov	a,m
	inx	h
	call	wrhex			; write byte at address
	call	space
	mov	a,b
	cpi	9
	cz	space			; one space after 8 bytes
	djnz	dumplinlp
;
dumplinasc:
	call	space
	IF	extended
	lxi	h,peekbuf
	ELSE
	pop	h
	ENDIF
	mvi	b,16
	mvi	a,'>'
	call	wrchar
dumpch:
	mov	a,m			; write as character
	inx	h
	call	iscontrol
	jrc	dumpch10
	mvi	a,'.'			; replace non-display char
dumpch10:
	call	wrchar
	djnz	dumpch
;
	mvi	a,'<'
	call	wrchar
;
	IF	extended
	pop	h
	lxi	b,16
	dad	b			; increase address
	ENDIF
	pop	b
	jmp	crlf			; exit via crlf
;
;
dumpwline:
	push	b
	IF	extended
	push	h
	call	peek
	ENDIF
	call	wraddr			; show address
	call	space2
;
	mvi	b,8
	IF	extended
	lxi	h,peekbuf
	ELSE
	push	h
	ENDIF
	push	d
dumpwlinlp:
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	xchg
	call	wrword			; write word at address
	call	space2
	xchg
	djnz	dumpwlinlp
;
	pop	d
	jr	dumplinasc
;
;
;------------------------------------------------------------------------------
;
;	E:	Execute command
;
	IF	fileops
;
exec:
	call	mexpression		; get condition
	rc				; default to FALSE if no expression
	call	getch
	cpi	';'
	rnz				; do nothing if no command
	mov	a,h
	ora	l			; true expression ?
	rz				; do nothing if false
	call	skipsep
	call	getch			; get command character
	jmp	moncmd			; execute command
;
	ENDIF
;
;------------------------------------------------------------------------------
;
;	G:	Go
;
go:
	xra	a
	sta	lastop			; this op may not be repeated
	sta	tmpbkflag
	call	expression		; get address to jump to
	jrnc	gogo			; ok if specified
	lhld	regpc			; else load default
	IF	extended
	lda	cbank
	ENDIF
;
gogo:
	shld	regpc
	IF	extended
	cpi	0ffh
	jrz	gogo10
	sta	cbank
	ENDIF
gogo10:
	call	skipsep
	lda	numbreaks		; current number of breakpoints
	mov	b,a
	call	getch
	jrz	gogoubk			; go if no further parameter
	cpi	';'
	jnz	cmderr			; error if not ';'
	call	expression		; get temp breakpoint
	jc	cmderr			; error if nothing after ;
	mov	c,a			; save bank
	lda	numbreaks		; number of breaks again
	mov	b,a
	mov	a,c			; bank number
	call	addbk			; add temp breakpoint
	ldy	a,3			; conditional ?
	ani	07fh			; mask off hi bit
	sty	a,3			; to mark unconditional
	lxi	h,numbreaks
	mov	a,m
	sub	b			; check if new break or old
	dcr	a
	sta	tmpbkflag		; save (-2 if new, -1 if old)
	mov	m,b
	siyd	tmpbkiy
;
gogoubk:
	call	eocmd
	jmp	unbreak			; and go
;
;
resettmpbk:
	lxi	h,tmpbkflag
	mov	a,m
	ora	a
	rz
	mvi	m,0
	liyd	tmpbkiy
	inr	a
	jrz	resetcond
	ldy	l,0
	ldy	h,1
	ldy	a,2
	jmp	deletebk
;
resetcond:
	ldy	a,3
	ora	a
	rz
	mviy	0ffh,3
	ret
;
;------------------------------------------------------------------------------
;
;	H:	Hex calculate
;
hexcalc:
	IF	hilo
	jz	dishighlow		; display high/low if no param
	ENDIF
	call	expression		; get the expression
	jc	cmderr			; error if no expression
hexcallp:
	xchg
	lxi	h,0
	dsbc	d			; negate
	xchg
	call	wrword			; write hex
	call	space2
	xchg
	mvi	a,'-'
	call	wrchar
	call	wrword			; write complement as hex
	call	space2
	xchg
	mvi	a,' '
	call	wrdec			; write decimal
	call	space2
	xchg
	mvi	a,'-'
	call	wrdec			; write complement as decimal
	call	space2
	xchg
	mov	a,h
	call	wrbit			; write as bit string
	mov	a,l
	call	wrbit
	call	space2
	mvi	a,''''
	call	wrchar			; write as character
	mov	a,l
	call	iscontrol
	jrc	hexcdisc		; ok if not a control character
hexcch:
	push	psw
	mvi	a,'^'			; mark control char
	call	wrchar
	pop	psw
	adi	40h
hexcdisc:
	call	wrchar
	mvi	a,''''
	call	wrchar
;
	IF	symbolic
	call	space2
	mvi	a,'.'
	call	wrsymbol
	ENDIF
;
	call	crlf
;
	call	sexpression
	jrnc	hexcallp		; display again if another expression
	jmp	eocmd
;
;
;------------------------------------------------------------------------------
;
;	I:	input from port
;
input:
	call	expression		; get port number
	jrnc	inp1			; ok if specified
	lhld	lastinp			; else use default
inp1:
	call	eocmd
	shld	lastinp			; store as default
	mov	b,h
	mov	c,l
	inp	e			; get byte
	mvi	a,'I'
;
portwr:
	call	wrchar			; write command identification
	lxi	h,portstr
	call	wrstr
	mov	a,c
	call	wrhex			; display port number
	lxi	h,sepstr
	call	wrstr
	mov	a,b
	call	wrhex			; display register B
	lxi	h,pendstr
	call	wrstr
	mov	a,e
	call	wrhex			; display data as hex
	call	space2
	mov	a,e
	call	wrbit			; display data as bitstring
	jmp	crlf
;
;
;	O:	Output to port
;
output:
	call	expression		; get data
	jrnc	outpa
	lhld	outdata			; use last data if not specified
	mov	a,h
	ora	a
	jz	cmderr			; error if no last data
outpa:
	mov	e,l
	mvi	h,0ffh
	shld	outdata			; store as default data
;
	push	d
	call	sexpression		; get port
	pop	d
	jrnc	outp1
	lhld	lastout			; use last port if no port number
outp1:
	call	eocmd
	shld	lastout			; store as default
	push	h
	mov	b,h
	mov	c,l
	mov	a,e
	push	psw
	mvi	a,'O'
	call	portwr			; display port & data
	pop	psw
	pop	b
	outp	a			; output data
	ret
;
;
portstr	db	'(Port=',0
sepstr	db	',B=',0
pendstr	db	'): ',0
;
;------------------------------------------------------------------------------
;
;	L:	Disassemble
;
list:
	call	expression		; from
	jrnc	list1
	lhld	listaddr		; use default if no from-address
	mvi	c,0ffh
	mvi	b,8			; mark 8 lines to list
	jr	list2
;
list1:
	IF	extended
	sta	listbnk
	ENDIF
	push	h
	call	sexpression		; to
	pop	d
	xchg				; from into HL
	mvi	c,0
	jrnc	list2			; ok if to given
;
	mvi	c,0ffh
	mvi	b,8			; else mark 8 lines to list
list2:
	call	eocmd
	push	d			; save to-address
;
listloop:
	push	b
	IF	extended
	lda	listbnk
	ENDIF
	mvi	b,0ffh
	call	disasm			; disassemble line
	shld	listaddr		; store next addr as next default
	call	crlf
	pop	b
	bit	0,c			; 8 lines ?
	jrz	listcmp			; branch if to-address given
	djnz	listloop		; else use count
	pop	d
	ret
;
listcmp:
	pop	d			; to-address
	push	d
	xchg
	ora	a
	dsbc	d			; to - current
	xchg
	jrnc	listloop		; list if current <= to
	pop	d
	ret
;
;------------------------------------------------------------------------------
;
;	M:	Move memory
;
move:
	call	expression		; start
	jc	cmderr			; error if no start-addr
	push	h
	IF	extended
	sta	mvsrcbnk
	ENDIF
	call	sexpression		; end
	jc	cmderr
	push	h
	call	sexpression		; to
	jc	cmderr
	IF	extended
	sta	mvdstbnk
	sta	pbank			; set bank for poke
	ENDIF
	call	eocmd
;
	pop	d			; end into DE
	xthl				; to-addr on stack, get start
	xchg				; end into HL
	ora	a
	dsbc	d			; end - start
	jc	cmderr			; error if start > end
	inx	h			; length + 1
;
	IF	extended
;
	push	h			; save length
	mvi	b,4			; divide by 16
movlp1:
	srlr	h
	rarr	l
	djnz	movlp1
	mov	b,h
	mov	c,l		; move number of 16-byte chunks into BC
	pop	h		; length
	xthl			; to-addr into HL, length on stack
	xchg			; dest into DE, start into HL
	lda	mvsrcbnk	; source bank
	call	peeks		; peek into string
;
movloop:
	mov	a,b
	ora	c
	jrz	movend		; branch if no further 16-bit chunks
	push	b
	lxi	b,16
	dad	b		; increase source addr
	xchg
	shld	paddr		; set poke-address
	dad	b		; increase dest addr
	push	d		; save dest
	push	h		; save source
	lxi	h,string
	lxi	d,peekbuf
	ldir			; copy string -> peek/poke buffer
	pop	d		; restore source
	pop	h		; restore dest
	lda	mvsrcbnk
	call	peeks		; get next chunk into string
	call	poke		; write into destination
	pop	b		; number of chunks
	dcx	b
	jr	movloop		; loop
;
movend:
	xchg			; destination
	pop	b		; original length
	mov	a,c		; remainder
	ani	0fh		; of division by 16
	rz			; ready if no remaining bytes to move
	mov	c,a
	mvi	b,0
	lda	mvdstbnk
	call	peek		; peek destination
	lxi	h,string
	lxi	d,peekbuf
	ldir			; copy string into destination
	jmp	poke		; write it
;
	ELSE
;
	mov	b,h
	mov	c,l		; length into BC
	pop	h
	push	h		; get & save to
	ora	a
	dsbc	d		; to - start
	pop	h		; to again
	xchg			; HL = source, DE = dest
	jrnc	move80		; jump if to >= start
	ldir
	ret
;
move80:
	dcx	b
	dad	b
	xchg
	dad	b
	xchg
	inx	b
	lddr
	ret
;
	ENDIF
;
;------------------------------------------------------------------------------
;
;	N:	Name definition
;
	IF	symbolic
;
namedef:
	jz	dissymbols
	IF	fileops
	cpi	'W'		; write symbols
	jrnz	namedef10
	call	getch
	call	skipsep
	jmp	symwrite
;
namedef10:
	cpi	'F'
	jrnz	namedef15
	call	getch
	call	skipsep
	jz	cmderr
	jmp	sfile		; set filename
;
namedef15:
	cpi	'S'		; reserve space
	jrnz	namedef20
	call	getch
	call	sexpression
	jc	cmderr
	call	eocmd
	jmp	rsvsym
;
namedef20:
	ENDIF
	cpi	'X'		; kill symbol
	jrz	namekill
	IF	fileops
	cpi	'R'		; symbol read ?
	jrnz	namdefloop
	call	getch
	call	sexpression
	jmp	readsym
	ENDIF
;
namdefloop:			; define symbol
	call	sexpression
	jc	cmderr
	push	h
	call	rdsymname
	jc	cmderr
	pop	d
	call	defsymbol
	call	skipsep
	jrnz	namdefloop
	ret
;
namekill:
	call	getch
	call	skipsep
	jrz	namekall
;
namekloop:
	call	rdsymname
	jc	cmderr
	jz	cmderr
	call	killsymbol
	call	skipsep
	jrnz	namekloop
	ret
;
namekall:
	lhld	symstart
	IF	fileops
	shld	symtop
	ELSE
	shld	topval
	ENDIF
	ret
;
	ENDIF
;
;------------------------------------------------------------------------------
;
;	P:	Protect
;
protect:
	jrz	protlst		; list if no param
	cpi	'X'
	jrz	protdel		; delete if X
	pushix
	pop	h
	lxi	d,protexpbuf
	lxi	b,80
	ldir			; copy buffer
	call	mexpression	; evaluate once to trap errors
	jrc	proterr
	call	testch
	rz
proterr:
	call	protdel
	jmp	cmderr
;
protdel:
	lxi	h,0
	shld	protexpbuf	; mark buffer empty
	ret
;
protlst:
	lxi	h,protexpbuf
	call	wrstr		; write expression
	jmp	crlf
;
;
;------------------------------------------------------------------------------
;
;	Q:	Query memory for a byte string
;
query:
	cpi	'J'		; justified ?
	mvi	a,0
	jrnz	query1
	call	getch		; skip J
query1:
	sta	querjust	; set justified flag
	call	sexpression	; start
	jc	cmderr
	IF	extended
	sta	querbnk
	ENDIF
	push	h
	call	sexpression	; end
	jc	cmderr
	push	h
;
	call	skipsep
	call	bytestring	; assemble string to look for
	jc	cmderr
;
	pop	h		; end
	pop	d		; start
	dsbc	d		; end - start
	jc	cmderr		; error if end < start
	inx	h		; length
	xchg			; addr into HL, length into DE
;
querloop:
	lxix	string
	ldx	c,-1		; string length
	push	h		; save start
	IF	extended
querloop1:
	lda	querbnk
	call	peek		; get memory
	push	d
	lxi	d,16
	dad	d		; increase memory addr
	pop	d
	mvi	b,16
	push	h
	lxi	h,peekbuf
	ENDIF
quercmp:
	ldx	a,0
	cmp	m
	jrnz	quernxt		; branch if unequal
	inx	h
	inxix
	dcr	c
	IF	extended
	jrz	quermatch	; match if string length expired
	djnz	quercmp		; loop for 16 bytes in chunk
	pop	h
	jr	querloop1	; get next 16-byte chunk
	ELSE
	jrnz	quercmp
	ENDIF
;
;
quermatch:
	IF	extended
	pop	h		; discard current addr
	ENDIF
	pop	h		; get start addr
	push	h		; and save
	push	d
	lda	querjust	; justified ?
	ora	a
	jrz	quermat1
	lxi	d,8
	dsbc	d		; display 8 bytes before addr if justified
quermat1:
	IF	extended
	lda	querbnk
	ENDIF
	call	dumpline	; dump the matching line
	pop	d
	IF	extended
	push	h		; dummy push
	ENDIF
;
quernxt:
	IF	extended
	pop	h		; discard current addr
	ENDIF
	pop	h		; start addr again
	inx	h		; next addr to compare
	dcx	d		; decrease count
	mov	a,d
	ora	e
	rz			; ready if count exprired
	jr	querloop	; else try again to find match
;
;
;------------------------------------------------------------------------------
;
;	R:	Read
;
	IF	fileops
;
fread:
;
	call	expression	; offset
	jmp	read		; continue in system dependent part
;
	ENDIF
;
;------------------------------------------------------------------------------
;
;	S:	Substitute
;
substit:
	call	expression	; substitution address
	jrnc	substit10
	call	eocmd
	lhld	asmaddr		; use default if no start addr
	jr	subsmain
;
substit10:
	IF	extended
	sta	asmbnk
	ENDIF
	push	h
	call	skipsep
	call	bytestring	; specified in command ?
	pop	h
	jrc	subsmain	; normal substit if not
	call	subslinp	; substitute
	shld	asmaddr		; set new default
	ret			; and exit
;
subsmain:
	shld	asmaddr		; set new default
	IF	extended
	lda	asmbnk
	call	peek		; get memory
	ENDIF
	call	wraddr		; show address
	call	space2
	IF	extended
	lda	peekbuf
	ELSE
	mov	a,m
	ENDIF
	call	wrhex		; show byte at address
	call	space2
	push	h
	call	readstring	; get input line
	pop	h
	jrz	subs10		; next if empty
	cpi	'.'
	rz			; exit if dot
	push	h
	call	bytestring	; get byte string
	jc	cmderr		; error if something else
	pop	h		; restore address
	call	subsline	; substitute
	jr	subsmain
;
subs10:
	inx	h		; next address
	jr	subsmain
;
;
subslinp:
	IF	extended
	lda	asmbnk
	call	peek		; get memory
	ENDIF
subsline:
	IF	extended
	xchg			; addr into DE
	ENDIF
	mov	c,b		; string length into C
subslinlp:
	IF	extended
	mvi	b,16		; length of a chunk
	lxi	h,peekbuf
	ENDIF
subsloop:
	ldx	a,0		; get byte
	mov	m,a		; store at address
	inx	h
	inxix
	IF	extended
	inx	d		; increase addr, too
	ENDIF
	dcr	c
	IF	extended
	jrz	subslex		; ready if string count reached
	djnz	subsloop	; loop for all 16 bytes	in chunk
	call	poke		; store the 16 bytes
	xchg			; addr again
	mov	b,c
	jr	subslinp	; get next 16-byte chunk
	ELSE
	jrnz	subsloop
	ENDIF
;
subslex:
	IF	extended
	call	poke		; store back
	xchg			; restore HL (addr)
	ENDIF
	ret
;
;
;------------------------------------------------------------------------------
;
;	C:	Trace over Calls
;	T:	Trace
;
calltrace:
	mvi	a,0ffh
	jr	trace1
trace:
	xra	a
trace1:
	sta	trcallopt		; trace over calls option
	xra	a
	sta	traceexp		; init options
	sta	tracenl
	sta	tracejp
trace2:
	call	testch
	cpi	'N'			; no list ?
	jrz	trace21
	cpi	'J'			; jumps only ?
	jrz	trace22
	cpi	'W'			; while ?
	jrz	trace23
	cpi	'U'			; until ?
	jrnz	trace3
	mvi	a,80h			; mark until
	jr	tracewu
;
trace21:
	sta	tracenl			; mark no list
trace29:
	call	getch			; skip char
	jr	trace2			; check for other options
;
trace22:
	sta	tracejp			; mark jumps only
	jr	trace29
;
;	trace with count
;
trace3:
	call	sexpression		; get number of ops to trace
	jrnc	trace10
	lxi	h,1			; default is 1
trace10:
	call	eocmd
	mov	a,h
	ora	l
	jz	cmderr			; error if zero count
	shld	tracecount		; save
	jmp	dotrace			; doit
;
;	trace while/until
;
trace23:
	mvi	a,07fh			; mark while
tracewu:
	sta	traceexp		; mark expression kind
	call	getch			; skip W/U
	call	skipsep
	sixd	traceptr		; remember position in line
	call	mexpression		; evaluate once to trap errors
	jc	cmderr
	call	testch
	jnz	cmderr			; error if something left on line
	lxi	h,0ffffh
	shld	tracecount		; set dummy trace count
	jmp	dotrace			; go trace
;
;
;------------------------------------------------------------------------------
;
;	V:	Verify memory
;
verify:
	call	expression		; start
	jc	cmderr			; error if no start-addr
	push	h
	IF	extended
	sta	mvsrcbnk
	ENDIF
	call	sexpression		; end
	jc	cmderr
	push	h
	call	sexpression		; to
	jc	cmderr
	call	eocmd
;
	IF	extended
	sta	mvdstbnk
	ENDIF
	pop	d			; end into DE
	xthl				; to-addr on stack, get start
	xchg				; end into HL
	ora	a
	dsbc	d			; end - start
	jc	cmderr			; error if start > end
	inx	h			; length + 1
	mov	b,h
	mov	c,l			; length into BC
	pop	h
	xchg				; dest into DE, start into HL
;
verifyloop:
	IF	extended
	push	b
	lxi	b,16
	lda	mvsrcbnk		; source bank
	call	peek			; source into peekbuf
	dad	b			; inc source addr
	xchg
	lda	mvdstbnk
	call	peeks			; dest into string
	dad	b			; inc dest addr
	pop	b
;
	push	h			; save dest
	push	d			; save source
	lxi	d,string
	lxi	h,peekbuf
	mvi	a,16
verify10:
	push	psw
	ENDIF
	ldax	d
	cmp	m
	cnz	verifyerr	; display if mismatch
	inx	h
	inx	d
	dcx	b
	mov	a,b
	ora	c
	IF	extended
	jrnz	verify20
	pop	psw
	pop	d
	pop	h
	ret
;
verify20:
	pop	psw
	dcr	a
	jrnz	verify10
	pop	h		; source
	pop	d		; dest
	jr	verifyloop
	ELSE
	jrnz	verifyloop
	ret
	ENDIF
;
verifyerr:
	IF	extended
	push	h
	push	d
	push	b
	mov	c,a
	mov	b,m
	lxi	d,peekbuf
	ora	a
	dsbc	d
	push	h		; offset
	lded	paddr
	dad	d		; source addr + offset
	lda	mvsrcbnk
	call	wraddr		; write source addr
	call	space
	mov	a,b
	call	wrhex		; write source byte
	call	space2
	lhld	psaddr
	pop	d
	dad	d		; dest addr + count
	lda	mvdstbnk
	call	wraddr		; write dest addr
	call	space
	mov	a,c
	call	wrhex		; write dest byte
	call	crlf
	pop	b
	pop	d
	pop	h
	ret
;
	ELSE
;
	call	wraddr
	call	space
	mov	a,m
	call	wrhex
	call	space2
	xchg
	call	wraddr
	call	space
	mov	a,m
	call	wrhex
	call	crlf
	xchg
	ret
;
	ENDIF
;
;
;------------------------------------------------------------------------------
;
;	W:	Write
;
	IF	fileops
;
fwrite:
	call	expression		; from
	jc	cmderr
	push	h
	push	psw
	call	sexpression		; to
	jc	cmderr
	xchg				; to into DE
	pop	psw			; bank
	pop	h			; from
	jmp	write			; continue in system dependent part
;
	ENDIF
;
;------------------------------------------------------------------------------
;
;	X:	where are we & register display/mod
;
where:
	jz	display			; display regs if no param
	cpi	''''
	jz	disalt			; display alternate regs
;
whereloop:
	call	rdregister		; read register name
	jc	cmderr			; error if none
	mov	b,a
	push	b
	push	h
	call	sexpression
	jrc	wheredis		; display if no expression
	pop	d
	pop	b
	push	psw
	mov	a,b
	ani	30h
	cpi	10h
	jrz	set8reg			; branch if 8-bit reg
	pop	psw
	call	putval
wherenxt:
	call	skipsep
	rz
	jr	whereloop
;
set8reg:
	xchg
	pop	psw
	mov	a,b
	cpi	17h
	jrz	setrr
	mov	m,e
	jr	wherenxt
;
setrr:
	mov	a,e
	star
	jr	wherenxt
;
;
wheredis:
	pop	h
	pop	b
	mov	a,b
	ani	30h
	cpi	10h
	jrz	mod8reg			; branch if 8-bit reg
;
wheremod:
	push	h			; save reg addr
	mov	e,m
	inx	h
	mov	d,m			; get contents
	xchg
	call	wrword			; write contents
	call	whereget		; get replacement
	pop	d			; restore reg addr
	rc				; ret if no change
putval:
	xchg
	mov	m,e			; store new value
	inx	h
	mov	m,d
	lxi	b,regpc+1		; was it PC ?
	ora	a
	dsbc	b
	rnz				; ready if not
	IF	extended
	call	xltbank			; adjust bank
	sta	cbank			; set new bank
	ENDIF
	sded	listaddr		; set new default list addr
	ret
;
;
mod8reg:
	mov	a,b
	cpi	17h			; R ?
	jrz	modrr			; R is special
	push	h			; save address
	mov	a,m
	call	wrhex			; show value
	call	whereget		; get replacement
	pop	d
	rc				; ready if no change
	xchg
	mov	m,e			; store value
	ret
;
modrr:
	ldar				; get current value of R
	call	wrhex			; display
	call	whereget
	rc
	star				; set new value
	ret
;
;
whereget:
	call	space2
	call	readstring		; get input line
	stc
	rz				; ready if no replacement
	call	sexpression		; get value
	jc	cmderr
	jmp	eocmd
;
;------------------------------------------------------------------------------
;
;	Y:	Display/change Y-variables
;
yvar:
	jz	disyvars		; display if no parameter
	call	expression
	jc	cmderr			; error if no number
setyloop:
	mov	a,h
	ora	a
	jnz	cmderr
	mov	a,l
	cpi	10
	jnc	cmderr
	add	a			; digit * 2
	mov	e,a
	mvi	d,0
	lxi	h,variables
	dad	d			; address variable
	push	h
	call	sexpression
	xchg
	pop	h
	jrc	wheremod		; continue like for register
	mov	m,e
	inx	h
	mov	m,d
	call	sexpression
	rc
	jr	setyloop
;
;
;------------------------------------------------------------------------------
;
;	Z:	Zap memory with constant
;
zap:
	call	expression		; from
	jc	cmderr
	IF	extended
	sta	zapbnk
	ENDIF
	push	h
	call	sexpression		; to
	jc	cmderr
	push	h
	call	skipsep
	call	bytestring		; value
	jc	cmderr
;
	pop	h			; to
	pop	d			; from
	dsbc	d			; to - from
	jc	cmderr			; error if to < from
	inx	h
	xchg				; length in DE, addr in HL
	lxix	string
	ldx	c,-1			; string length
;
zaploop:
	IF	extended
	lda	zapbnk
	call	peek			; get memory
	push	d
	lxi	d,16
	dad	d			; increase addr
	pop	d
	push	h
	mvi	b,16
	lxi	h,peekbuf
zaploop2:
	ENDIF
	ldx	a,0			; copy bytes into destination
	mov	m,a
	inx	h
	inxix
	dcx	d
	mov	a,d
	ora	e
	IF	extended
	jrz	zapend			; ready if all bytes zapped
	ELSE
	rz
	ENDIF
	dcr	c
	IF	extended
	jrnz	zaploop10		; loop if more bytes in string
	ELSE
	jrnz	zaploop
	ENDIF
	lxix	string
	ldx	c,-1			; go back to start of string
zaploop10:
	IF	extended
	djnz	zaploop2		; loop for all 16 bytes in chunk
	call	poke			; store back
	pop	h
	ENDIF
	jr	zaploop			; get next chunk
;
	IF	extended
zapend:
	pop	h
	jmp	poke			; return via poke
;
	ENDIF
;
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;
	dseg
;
varstart:
;
tmpbkflag	ds	1
tmpbkiy		ds	2
;
listaddr	ds	2		; default list
		IF	extended
listbnk		ds	1
		ENDIF
dumpaddr	ds	2		; default dump
		IF	extended
dumpbnk		ds	1
		ENDIF
asmaddr		ds	2		; default assemble/substitute
		IF	extended
asmbnk		ds	1
		ENDIF
lastinp		ds	2		; default input port
lastout		ds	2		; default output port
outdata		ds	2		; default output data
lastop		ds	1		; last command
dumpword	ds	1		; dump word if lastop is dump command
tracecount	ds	2		; number of lines to trace
trcallopt	ds	1		; trace over calls if <> 0
tracenl		ds	1		; trace without list if <> 0
tracejp		ds	1		; trace jumps only if <> 0
traceexp	ds	1		; trace while if 7f, until if 80
traceptr	ds	2		; expression pointer for trace U/W
variables	ds	20		; variables Y0..Y9
		IF	hilo
lowval		ds	2		; special variable L
highval		ds	2		; special variable H
maxval		ds	2		; special variable M
topval		ds	2		; special variable T
		ENDIF
protexpbuf	ds	80		; expression for trace protection
bkexpbuf	ds	80		; expression for BREAK IF
;
		IF	extended
bnktmp1		ds	1
bnktmp2		ds	1
		ENDIF
movdest		ds	2
;
		IF	extended
zapbnk		equ	bnktmp1
mvsrcbnk	equ	bnktmp1
mvdstbnk	equ	bnktmp2
querbnk		equ	bnktmp1
querjust	equ	bnktmp2
		ELSE
querjust	ds	1
		ENDIF
;
;
varspace	equ	$-varstart
;
	ds	256			; stack space
stack:
	end

