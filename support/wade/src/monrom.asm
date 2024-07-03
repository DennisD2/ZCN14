	title	'System dependent routines for monitor'
;
;	Last Edited	85-04-27	Wagner
;
;       This is a sample for a ROM-based version of WADE, running on a
;       Z80 with ROM from 0000..3fff and RAM from 4000..7fff.
;       A Z80-SIO is used to communicate with the host.
;       In normal operations, the host acts as a dumb terminal.
;       For down- and uploads of code and symbols, communication 
;       switches to a block-oriented minimum protocol.
;
;       
;	Written 1984, 1985 by
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
	maclib	ports
;
siodata	equ	s2adata
sioctl	equ	s2actl
rca	equ	1
tbe	equ	4
;
xon	equ	'Q'-'@'
xoff	equ	'S'-'@'
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
	public	resetrst
;
;
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
;
	extrn	codend,stack
	extrn	syminit
;
;------------------------------------------------------------------------------
;
;       The following code is entered on CPU Reset.
;       Note that this module must be linked first, as in all versions.
;
;------------------------------------------------------------------------------
;
start:
	di				; 0
	jmp	initialise		; 1, 2, 3
;
	dw	codend			; 4, 5
	nop				; 6
	nop				; 7
;
;	RST 8
;
	jmp	break	
;
;
;
modebit	equ	0cfh
;
inactive	equ	11110000B
prtbit	equ	02h
beepbit	equ	04h
baudbit	equ	30h
rembit	equ	40h
;
lcddata	equ	p1bdata
lcdctl	equ	p1bctl
;
intctl	equ	07h
intoff	equ	03h
;
bitmask	equ	00001001B
;
;       Here the peripherals of the system are initialised.
;       This must be changed to reflect your target system.
;
initialise:
;       Init PIO
	mvi	a,inactive
	out	p1adata
	mvi	a,modebit
	out	p1actl
	mvi	a,bitmask
	out	p1actl
;       Init CTC
	mvi	a,43h		; reset
	out	ctc0
	out	ctc1
	out	ctc2
	out	ctc3
	mvi	a,47h		; reset & load
	out	ctc0
	mvi	a,13
	out	ctc0
	mvi	a,47h		; reset & load
	out	ctc1
	mvi	a,13
	out	ctc1
	mvi	a,47h		; reset & load
	out	ctc2
	mvi	a,13
	out	ctc2
	mvi	a,47h		; reset & load
	out	ctc3
	mvi	a,125
	out	ctc3
;       Init second PIO
	mvi	a,modebit
	out	p2actl
	mvi	a,0ffh
	out	p2actl
	mvi	a,modebit
	out	p2bctl
	mvi	a,0c0h
	out	p2bctl
	xra	a
	out	p2bdata
;       Init LCD Display
	mvi	a,intoff
	out	lcdctl
	mvi	a,intctl
	out	lcdctl
	mvi	a,modebit
	out	lcdctl
	mvi	a,0ffh
	out	lcdctl
	xra	a
	out	lcdrs
	out	lcdrw
	out	lcdena
;       Init SIOs
	lxi	h,s1atab
	mvi	c,s1actl
	mvi	b,s1alen
	outir
	mvi	c,s1bctl
	mvi	b,s1blen
	outir
	mvi	c,s2actl
	mvi	b,s2alen
	outir
	mvi	c,s2bctl
	mvi	b,s2blen
	outir
	in	s1adata
	in	s1bdata
	in	s2adata
	in	s2bdata
;
;-----------------------------------------------------------------------
;       Init of target system complete, go to monitor entry.
;
	jmp	monent
;
;       SIO Init tables
;
s1atab:
	db	18h,18h
	db	4,01000100B
	db	3,11000001B
	db	5,01101000B
	db	1,00000100B
;
s1alen	equ	$-s1atab
;
s1btab:
	db	18h,18h
	db	4,01000100B
	db	3,11000001B
	db	5,01101000B
	db	2,s1itab
	db	1,00000100B
;
s1blen	equ	$-s1btab
;
s2atab:
	db	18h,18h
	db	4,01000100B
	db	3,11000001B
	db	5,01101000B
	db	1,00000100B
;
s2alen	equ	$-s2atab
;
s2btab:
	db	18h,18h
	db	4,01000100B
	db	3,11000001B
	db	5,01101000B
	db	2,s2itab
	db	1,00000100B
;
s2blen	equ	$-s2btab
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
;       Initialises all debugger variables.
;
initsystem:
	xra	a
	sta	chrbuf
;
	lxi	h,8000h
	shld	listaddr
	shld	dumpaddr
	shld	asmaddr
	IF	hilo
	shld	lowval
	shld	highval
	shld	maxval
	ENDIF
	shld	regpc
	lxi	h,varbase-1
	shld	topval
	lxi	d,0
	mov	m,d
	dcx	h
	mov	m,e
	shld	regsp		; set sp to bottom, with retaddr = debexit
;
	lxi	h,prot
	lxi	d,protexpbuf
	lxi	b,protl
	ldir
	call	syminit
;
	lxi	h,hallo
	call	wrstr
	ret
;
hallo:
	db	'WADE 1.5',0
;
prot:
	db	'RPC<8000',0
protl	equ	$-prot
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
	call	pollch
	jrz	rdchar
	lda	chrbuf
	ora	a
	jrz	getsio
	push	psw
	xra	a
	sta	chrbuf
	pop	psw
	jr	rdcw
getsio:
	in	siodata
	ani	7fh
rdcw:
	cpi	6
	rnc
	cpi	4
	rc
	call	block
	jmp	rdchar
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
	lda	chrbuf
	ora	a
	jrnz	pollok
	in	sioctl
	ani	rca
	rz
pollok:
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
	push	psw
wrcwt:
	in	sioctl
	ani	tbe
	jrz	wrcwt
wrcwxon:
	pop	psw
	out	siodata
	push	psw
	push	h
waitecho:
	lxi	h,7fffh
wrecho:
	in	sioctl
	ani	rca
	jrnz	gotecho
	dcx	h
	mov	a,h
	ora	l
	jrnz	wrecho
	pop	h
	pop	psw
	ret
;
gotecho:
	in	siodata
	ani	7fh
	cpi	1
	jrnz	noecho
	pop	h
	pop	psw
	ret
;
noecho:
	sta	chrbuf
	jr	waitecho
;
;
block:
	push	b
	push	h
	mov	c,a
	mvi	a,2
	call	blkwrite
;
	call	blkread
	mov	l,a
	call	blkread
	mov	h,a
	mvi	b,128
	mov	a,c
	cpi	5
	jrz	rblock
wblock:
	call	blkread
	mov	m,a
	inx	h
	djnz	wblock
	pop	h
	pop	b
	ret
;
blkread:
	in	sioctl
	ani	rca
	jrz	blkread
	in	siodata
	ret
;
rblock:
	mov	a,m
	call	wrchar
	inx	h
	djnz	rblock
	pop	h
	pop	b
	ret
;
blkwrite:
	push	psw
blkwrlp:
	in	sioctl
	ani	tbe
	jrz	blkwrlp
	pop	psw
	out	siodata
	ret
;
;------------------------------------------------------------------------------
;
killmac:
jmacro:
userdef:
read:
write:
file:
	ret
;
;
;
restartinst	equ	0cfh	; RST 08
restartloc	equ	08h
;
;
	public	restart,rstloc
;
	public	goto
;
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
setrst:
resetrst:
	ret
;
;
restart	db	restartinst
rstloc	db	restartloc
;
;
;
;------------------------------------------------------------------------------
;
	dseg
;
varbase:
;
chrbuf	ds	1
;
	end	start

