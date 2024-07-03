	title	'Break/Trace/Display Module for Monitor'
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
	maclib	z80
	maclib	monopt
;
	public	break
;
	public	display,disalt,disyvars
;
	IF	hilo
	public	dishighlow
	ENDIF
;
	public	initbreak,unbreak,dotrace
	public	deletebk,definebk,addbk,resetbk,nresetbk
;
	public	numbreaks,breaklist
	public	regi,regiff,regbc,regpc,regsp,altbc,iffstr
;
	extrn	initcio
	extrn	resetrst
	extrn	string
;
	IF	extended
	public	cbank
	extrn	peek,poke,currbank,peekbuf,xltbank
	ENDIF
;
	extrn	goto
	extrn	wrstr,wrchar,wrhex,wrword,space,space2,crlf,tkbint
	extrn	mexpression
	extrn	monitor,cmderr,stack
	extrn	disasm,analop,jumpaddr,jumpmark
	extrn	tracecount,trcallopt,tracejp,tracenl,traceexp,traceptr
	extrn	bkexpbuf,protexpbuf
	extrn	listaddr,restart,rstloc
	extrn	variables
;
	IF	hilo
	extrn	lowval
	ENDIF
;
	cseg
;
maxbreaks	equ	8
;
;
;	Display:
;
;123456789.123456789.123456789.123456789.
;F=76543210  A=xx BC=xxxx DE=xxxx HL=xxxx IX=xxxx PC=xxxx    instruction
;     IFF=x  I=xx IY=xxxx SP=xxxx (xxxx xxxx xxxx xxxx xxxx) LD    (IX+00),00
;F'=76543210 A'=xx BC'=xxxx DE'=xxxx HL'=xxxx M=xx
;
;F=76543210 A=xx BC=xxxx DE=xxxx PC=xxxx 12345678:   1234567890123456  .1234567
;IFF=x I=xx HL=xxxx IX=xxxx IY=xxxx SP=xxxx (xxxx xxxx)
;
;
;	disflags:	Display flag register
;
disflags:
	push	psw
	call	disregnam
	pop	psw
	lxi	h,flagnames
	mvi	b,8
disfll:
	rlc
	push	psw
	jrnc	disfloff
	mov	a,m
	jr	disflxx
disfloff:
	mvi	a,'.'
disflxx:
	call	wrchar
	inx	h
	pop	psw
	djnz	disfll
	jmp	space
;
flagnames	db	'SZxHxPNC'
;
;
;
;	display:	display CPU state (primary regs only)
;
display:
	lxi	d,reg1nam
	lda	regf
	call	disflags		; display flags
	lxi	h,rega
	call	dis8reg			; display A
;
	lxi	h,regbc
	IF	symbolic
	mvi	b,2
	ELSE
	mvi	b,3
	ENDIF
displ10:
	call	dis16reg		; display BC, DE, HL
	djnz	displ10
	IF	NOT symbolic
	lxi	h,regix
	call	dis16reg		; IX
	ENDIF
;
	call	disregnam		; 'PC='
	IF	extended
	lda	cbank
	ENDIF
	lhld	regpc
	mvi	b,0
	call	disasm			; disassemble at PC
	shld	newpc			; save next PC
	call	crlf
;
	lxi	d,reg2nam
	call	disregnam		; 'IFF='
	lda	regiff
	ani	1
	ori	30h
	call	wrchar			; display IFF
	call	space
	lxi	h,regi
	call	dis8reg			; display I
;
	IF	symbolic
	lxi	h,reghl
	call	dis16reg
	lxi	h,regix
	call	dis16reg
	call	dis16reg
;
	ELSE
;
	lxi	h,regiy
	call	dis16reg		; IY
	ENDIF
;
	call	disregnam		; 'SP='
	lhld	regsp
	call	wrword			; display SP
	call	space
	IF	extended
	lda	cbank
	call	peek
	ENDIF
	mvi	a,'('
	call	wrchar
	IF	symbolic
	mvi	b,2
	ELSE
	mvi	b,5			; display 5 words at bottom of stack
	ENDIF
	IF	extended
	lxi	h,peekbuf
	ENDIF
displayl3:
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	xchg
	call	wrword			; display (SP)
	xchg
	dcr	b
	jrz	displayend
	call	space
	jr	displayl3
;
displayend:
	mvi	a,')'
	call	wrchar
	jmp	crlf
;
	IF	symbolic
;
reg1nam	db	'F=A=BC=DE=PC='
reg2nam:
iffstr	db	'IFF=I=HL=IX=IY=SP='
;
	ELSE
;
reg1nam	db	'F= A=BC=DE=HL=IX=PC='
reg2nam	db	'     '
iffstr	db	'IFF= I=IY=SP='
;
	ENDIF
;
;
;	disalt:		display alternate registers
;
disalt:
	lda	altaf
	lxi	d,reganam
	call	disflags
	lxi	h,altaf+1
	call	dis8reg			; display A'
	lxi	h,altbc
	mvi	b,3
disaltlp:
	call	dis16reg		; display BF', DE', HL'
	djnz	disaltlp
	IF	extended
	lxi	h,cbank
	call	dis8reg
	ENDIF
	jmp	crlf
;
;
reganam	db	'F''=A''=BC''=DE''=HL''='
	IF	extended
	db	' X='
	ENDIF
;
;	disyvars:	display Y-variables
;
disyvars:
	lxi	h,variables
	mvi	b,10
	mvi	c,'0'
disylp:
	mvi	a,'Y'
	call	wrchar
	mov	a,c
	call	wrchar
	mvi	a,'='
	call	wrchar
	call	disword
	call	space
	inr	c
	mov	a,c
	cpi	'5'
	cz	crlf
	djnz	disylp
	jmp	crlf
;
;
	IF	hilo
;
;	dishighlow:	display High, Low and Max
;
dishighlow:
	lxi	d,hilostr
	lxi	h,lowval
	mvi	b,4
dishilo10:
	call	dis16reg
	djnz	dishilo10
	jmp	crlf
;
hilostr	db	'Low=  High=  Max=  Top='
;
	ENDIF
;
dis8reg:
	call	disregnam
	mov	a,m
	call	wrhex
	jmp	space
;
;
dis16reg:
	call	disregnam
	call	disword
	jmp	space
;
;
disword:
	push	d
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	xchg
	call	wrword
	xchg
	pop	d
	ret
;
;
disregnam:
	ldax	d
	inx	d
	call	wrchar
	cpi	'='
	rz
	jr	disregnam
;
;
;------------------------------------------------------------------------------
;
;
;	Breakpoint Entry
;
;
break:
	sspd	savsp			; save stackpointer
	lxi	sp,breakstack		; register save area
	push	psw			; AF
	ldai
	push	psw			; I & IFF
	IF	disint
	DI
	ENDIF
	pushiy
	pushix
	push	h			; dummy (AF)
	push	h			; dummy (SP)
	push	h			; HL
	push	d
	push	b
;
	exaf
	push	psw			; AF'
	exx
	push	h			; dummy (no SP')
	push	h			; HL'
	push	d			; DE'
	push	b			; BC'
	exx
	exaf				; back to old register set
	lxi	sp,stack		; local stack
;
	xra	a
	sta	regiff			; so peek does not enable interrupts
	IF	extended
	call	currbank
	sta	cbank
	ENDIF
	lhld	savsp			; stackpointer on entry
	IF	extended
	call	peek
	lxi	h,peekbuf
	ENDIF
	mov	e,m
	inx	h
	mov	d,m			; location at stackpointer = retaddr
	lhld	savsp
	inx	h
	inx	h			; point before retaddr on stack
	xchg				; retaddr into HL
	dcx	h			; address at RST
	IF	extended
	lda	cbank
	call	peek
	lda	peekbuf
	ELSE
	mov	a,m
	ENDIF
	push	h
	lxi	h,restart
	cmp	m			; is it RST ?
	pop	h
	jrnz	break15			; leave pc as is if not
	lda	breaklist
	mov	b,a
	push	d
	IF	extended
	lda	cbank
	call	xltbank
	ENDIF
	call	searchbk		; is it a breakpoint ?
	pop	d
	jrz	break20			; then reset PC to RST
break15:
	inx	h			; else leave PC as it is
break20:
	xchg
	shld	regsp			; store corrected SP
	lhld	regpc			; this contains I & IFF
	sded	regpc			; set corrected PC
	sded	listaddr		; new default list address
	shld	regiff			; store iff elsewhere
	lhld	savaf
	shld	regaf			; store AF at correct place
;
	lda	regiff
	rrc
	rrc
	ani	1
	push	psw
	xra	a
	sta	regiff
	call	resetbk			; reset breakpoints
	pop	psw
	sta	regiff			; shift P/V-Flag for IFF
	IF	disint
	jrz	break80			; exit if interrupts disabled
	ei				; else re-enable
	ENDIF
;
break80:
	call	initcio
	lhld	regpc			; current PC
	lda	numbreaks
	mov	b,a
;
	IF	zeroboot
	mov	a,h
	ora	l
	jz	breakwarm		; jump if warmboot
	ENDIF
;
	IF	extended
	lda	cbank
	call	xltbank
	ENDIF
	call	searchbk		; is this a normal breakpoint ?
	jrnz	breaktr			; check trace if not
	ldy	a,3			; conditional break ?
	ani	80h
	jz	breakexit		; exit if not conditional
	lxix	bkexpbuf
	call	mexpression		; evaluate condition
	jc	breakexit		; exit if bad
	mov	a,h
	ora	l
	jnz	breakexit		; exit if condition met
	lhld	tracecount
	mov	a,h
	ora	l
	jrnz	breaktr			; go trace if condition false
	call	tkbint
	jrnz	breakexit
	jmp	gounbreak		; continue if condition not met
;
;
breaktr:
	lhld	tracecount		; are we tracing ?
	mov	a,h
	ora	l
	jrnz	breaktr10		; then check trace conditions
	lda	temptrace
	ora	a
	jnz	gounbreak		; go if temporary trace
	jr	breakexit
;
breaktr10:
	lda	tracejp			; jumps only ?
	ora	a
	jrz	breaktr20		; next if not
	lhld	regpc
	IF	extended
	lda	cbank
	ENDIF
	call	analop			; analyse opcode
	lda	jumpmark		; jump ?
	ora	a
	jrz	brkdotr			; no list if no jump
;
breaktr20:
	lda	traceexp		; while/until ?
	ora	a
	jrz	break85			; continue if not
;
;	trace while/until
;
	lixd	traceptr		; load expression pointer
	call	mexpression
	jrc	breakexit		; exit on error
	lda	traceexp
	rlc
	jrc	breakuntil
	mov	a,h
	ora	l
	jrz	breakexit		; trace while: exit if false
	jr	break85
breakuntil:
	mov	a,h
	ora	l
	jrnz	breakexit		; trace until: exit if true
;
break85:
	lda	traceexp
	ora	a
	jrnz	break91			; no decrease if expression
	lhld	tracecount
	dcx	h			; else decrease count
	shld	tracecount
	mov	a,h
	ora	l
	jrz	breakexit		; and exit if zero
break91:
	lda	tracenl			; no list ?
	ora	a
	jrz	breakdis		; go if no list
brkdotr:
	call	tkbint			; check for int from keyboard
	jrnz	breakexit
	jmp	dotrace
;
breakdis:
	call	display			; display if list on
	jmp	dotrace			; and continue tracing
;
	IF	zeroboot
breakwarm:
	lxi	h,wbootmsg
	call	wrstr
	ENDIF
;
breakexit:
	call	display			; display next opcode
	jmp	monitor
;
	IF	zeroboot
wbootmsg	db	0dh,0ah,'WARM BOOT',0dh,0ah,0
	ENDIF
;
;------------------------------------------------------------------------------
;
;	unbreak:	return from break
;
;
gounbreak:
	lda	numbreaks
	mov	b,a
unbreak:
	xra	a
	sta	temptrace
	ora	b
	jrz	untrace		; go if no breakpoints
	push	b
	lhld	regpc
	IF	extended
	mvi	a,0ffh
	call	xltbank
	ENDIF
	call	searchbk	; break set at PC ?
	pop	b
	jrnz	untrace		; ok if not
	mvi	a,0ffh
	sta	temptrace	; mark temporary trace
	jmp	normtrace	; trace one op if break at PC
;
;
;	untrace:	return from break, tracing on
;
;		entry:	B = number of breakpoints (including temporary)
;
untrace:
	IF	disint
	DI
	ENDIF
	lda	regiff
	push	psw
	xra	a
	sta	regiff
	call	setbk
	pop	psw
	sta	regiff
;
	lxi	sp,altbc	; restore registers
	exx
	pop	b
	pop	d
	pop	h
	exx
	pop	psw		; i & iff
	stai
	exaf
	pop	psw
	exaf
	pop	b
	pop	d
	pop	h
	pop	psw		; dummy (SP)
	pop	psw		; AF
	popix
	popiy
	lxi	sp,string+80
	jmp	goto		; go to program
;
;
;------------------------------------------------------------------------------
;
;
;	setbk:		set breakpoints
;
;		entry:	B = number of breakpoints
;
setbk:
	lxix	breaklist+1
	stx	b,-1
	mov	a,b
	ora	a
	rz			; ret if no breakpoints
	mvi	c,5
	lded	regpc
setbkloop:
	ldx	l,0
	ldx	h,1
	IF	extended
	ldx	a,2
	call	peek
	lda	peekbuf
	ELSE
	mov	a,m
	ENDIF
	stx	a,4		; save previous memory contents
	IF	extended
	lda	cbank
	cmpx	2
	jrz	setbklp4	; check pc if same bank
	ldx	a,2
	inr	a		; default bank ?
	jrnz	setbklp5	; branch if different bank
	ENDIF
setbklp4:
	ora	a
	IF	NOT extended
	push	h
	dsbc	d
	pop	h
	ELSE
	dsbc	d
	ENDIF
	jrz	setbklp10	; dont set break at current PC
setbklp5:
	lda	restart
	IF	extended
	sta	peekbuf
	call	poke
	ELSE
	mov	m,a
	ENDIF
setbklp10:
	mov	a,b
	mvi	b,0
	dadx	b
	mov	b,a
	djnz	setbkloop
	ret
;
;
;	resetbk:	reset breakpoints and restart location
;	nresetbk:	reset breakpoints only
;
resetbk:
	call	resetrst
nresetbk:
	lxix	breaklist+1
	ldx	b,-1
	mov	a,b
	ora	a
	rz				; ret if no breakpoints
	lda	numbreaks
	stx	a,-1			; reset number of breakpoints
	lxi	d,5
resbkloop:
	ldx	l,0
	ldx	h,1
	IF	extended
	ldx	a,2
	call	peek
	lda	peekbuf
	lxi	h,restart
	cmp	m
	ELSE
	lda	restart
	cmp	m
	ENDIF
	jrnz	resbk1
	ldx	a,4
	IF	extended
	sta	peekbuf
	call	poke
	ELSE
	mov	m,a
	ENDIF
resbk1:
	dadx	d
	djnz	resbkloop
	ret
;
;
;------------------------------------------------------------------------------
;
;	dotrace:	execute one opcode, then break
;
dotrace:
	xra	a
	sta	temptrace
	lxix	protexpbuf		; protection
	call	mexpression
	jrc	normtrace		; ok if no protection
	mov	a,h
	ora	l
	jrz	normtrace		; ok if expression false
;
;	protected region, set break to return address
;
	call	tratsp
	lda	numbreaks
	mov	b,a
	mvi	a,0ffh			; default bank
	call	addbk			; set as temp breakpoint
	jmp	untrace
;
;	normal trace
;
normtrace:
	lhld	regpc
	IF	extended
	lda	cbank
	ENDIF
	call	analop
	shld	newpc
	lda	numbreaks		; number of breakpoints
	mov	b,a
	lda	jumpmark
	ora	a			; jump/call/ret instruction ?
	jrnz	dotrjump		; then we have to set a different break
dotr10:
	lhld	newpc			; next location
	mvi	a,0ffh
	call	addbk			; set as temporary breakpoint
	jmp	untrace			; execute
;
dotrjump:
	ani	070h
	cpi	20h
	jrc	dotrjimm		; 10 is immediate
	jrnz	dotrjreg		; 30 is to register
	call	tratsp			; 20 is to stack
dotrj10:
	mvi	a,0ffh
	call	addbk			; set as temp breakpoint
	lda	jumpmark
	ani	80h			; conditional ?
	jz	untrace			; go exec if not
	jr	dotr10			; enter normal
;
dotrjimm:
	lhld	jumpaddr		; immediate
	lded	regpc			; same as current PC ?
	ora	a
	dsbc	d
	jrnz	dotrjimmok		; ok if not same
	IF	extended
	lda	peekbuf			; peekbuf contains current opcode
	ELSE
	ldax	d
	ENDIF
	cpi	10h			; DJNZ ?
	jnz	cmderr			; abort if not
	jr	dotr10			; enter normal addr instead of jumpaddr
;
dotrjimmok:
	lhld	jumpaddr
	lda	jumpmark
	ani	1			; call ?
	jrz	dotrj10			; ok if not
	lda	trcallopt		; trace over calls ?
	ora	a
	jrnz	dotr10			; set normal break if yes
	jr	dotrj10			; else continue
;
dotrjreg:
	lda	jumpmark
	ani	7
	add	a
	mov	e,a
	mvi	d,0
	lxi	h,regbc
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	xchg
	jr	dotrj10
;
;
tratsp:
	lhld	regsp			; get return address
	IF	extended
	lda	cbank
	call	peek
	lxi	h,peekbuf
	ENDIF
	mov	e,m
	inx	h
	mov	d,m
	xchg
	ret
;
;------------------------------------------------------------------------------
;
;	addbk:		add a breakpoint to the list if not already present
;
;		entry:	HL = breakpoint address
;			B  = current number of breakpoints
;			A  = breakpoint bank
;
;		exit:	B = B + 1
;
addbk:
	IF	extended
	cpi	0ffh
	jrnz	addbk1
	call	xltbank
	ENDIF
addbk1:
	call	searchbk
	rz				; no change if already defined
	sty	l,0
	sty	h,1
	sty	a,2
	mviy	0,3			; clear condition flag
	inr	b
	ret
;
;
;	searchbk:	search for breakpoint
;
;		entry:	A/HL = address
;			B = number of breakpoints
;
;		exit:	zero-flag set if found
;			C = index if found
;			IY = breaklist pointer (end of list if not found)
;
searchbk:
	mov	d,a
	mov	e,b
	lxiy	breaklist+1
	mov	a,b
	ora	a
	jrnz	searchbk10
	dcr	a
	mov	a,d
	ret
searchbk10:
	mvi	c,0
searchbk20:
	ldy	a,0
	cmp	l
	jrnz	searchbk25	; no match if not same address
	ldy	a,1
	sub	h
	jrnz	searchbk25
	IF	extended
	ldy	a,2
	cmp	d
	jrnz	searchbk25	; no match if not same bank
	ENDIF
	mov	b,e		; match, return
	mov	a,d
	ret
;
searchbk25:
	push	d
	lxi	d,5
	dady	d
	pop	d
	inr	c
	djnz	searchbk20
	ori	0ffh
	mov	b,e
	mov	a,d
	ret
;
;
;	delbk:		delete breakpoint
;
;		entry:	IY = pointer to breakpoint list element
;			C = index
;
delbk:
	lxi	h,numbreaks
	dcr	m
	mov	a,m
	sta	breaklist
	sub	c		; elements after this element
	rz			; ready if nothing to move
	mov	c,a
delbklp:
	mvi	b,5
delbk10:
	ldy	a,5
	sty	a,0
	inxiy
	djnz	delbk10
	dcr	c
	jrnz	delbklp
	ret
;
;
;	deletebk:	delete breakpoint
;
;		entry:	A/HL = address
;
deletebk:
	pushiy
	push	psw
	lda	numbreaks
	mov	b,a
	pop	psw
	IF	extended
	cpi	0ffh
	cz	xltbank
	ENDIF
	call	searchbk
	jnz	cmderr
	call	delbk
	popiy
	ret
;
;
;	definebk:	add breakpoint
;
;
definebk:
	push	b
	lbcd	numbreaks-1		; get numbreaks into B
	call	addbk
	mvi	a,maxbreaks
	cmp	b
	jc	cmderr
	mov	a,b
	pop	b
	sty	c,3			; set condition flag
	sta	numbreaks
	sta	breaklist
	ret
;
;
;	initbreak:	init module variables
;
initbreak:
	lxi	h,vars
	lxi	d,vars+1
	lxi	b,varspace-1
	mvi	m,0
	ldir				; clear registers & breakpoints
	IF	extended
	call	currbank
	sta	cbank			; init current bank
	ENDIF
	ldai
	sta	regi			; init I-reg
	rpo				; leave IFF = 0 if interrupts disabled
	mvi	a,1
	sta	regiff			; init IFF
	ret
;
;
	dseg
;
vars:
;
altbc	ds	2
altde	ds	2
althl	ds	2
regiff	ds	2		; no alternate SP
regi	equ	regiff+1
altaf	ds	2
;
regbc	ds	2
regde	ds	2
reghl	ds	2
regsp	ds	2
regaf	ds	2
regf	equ	regaf
rega	equ	regaf+1
regix	ds	2
regiy	ds	2
regpc	ds	2
;
savaf	ds	2
breakstack	equ	$
;
savsp	ds	2
retloc	ds	2
newpc	ds	2
;
	IF	extended
cbank		ds	1
	ENDIF
;
temptrace	ds	1
numbreaks	ds	1
breaklist	ds	(maxbreaks+2)*5+1
;
; Break list format:
;
;	db	number of active entries
; each entry:
;	dw	address
;	db	bank	(unused for non-extended version)
;	db	condition-flag
;	db	storage for original contents of location
;
varspace	equ	$-vars
;
	end

