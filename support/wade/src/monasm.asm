	title	'Assembler Module for Monitor'
;
;	Last Edited	84-06-24	Wagner
;
;	Copyright (c) 1984 by
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
	public	assemble
	public	opnd1,opnd2
;
	extrn	srchmnemo,translate
;
	IF	symbolic
	extrn	rdsymname,defsymbol
	ENDIF
;
	IF	extended
	extrn	peek,poke,peekbuf
	ENDIF
;
	extrn	skipsp,skipsep,getch,testch,isletter
	extrn	rdregister,expression
	extrn	cmderr
	extrn	ccnam,caddress,string
;
	cseg
;
;	assemble:	assemble one line
;
;		entry:	A/HL = address
;
assemble:
	shld	caddress
	IF	extended
	push	psw
	ENDIF
;
	IF	symbolic
;
	pushix
	call	rdsymname
	jrc	assemnosym
	call	getch
	cpi	':'
	jrnz	assemnosym
	pop	d			; discard old IX
	lded	caddress
	call	defsymbol
	call	skipsep
	jr	assemsymbol
;
assemnosym:
	popix
assemsymbol:
;
	ENDIF
;
	lxi	h,'  '
	shld	opnd1
	shld	opnd1+2
	lxi	h,opnd1
	mvi	b,4
mnloop:
	call	getch
	call	isletter
	jrc	mnloop10
	mov	m,a
	inx	h
	djnz	mnloop
	call	getch
;
mnloop10:
	ora	a
	jrz	mnloop11
	cpi	' '
	jnz	cmderr
mnloop11:
	lxi	h,opnd1
	call	srchmnemo
	jc	cmderr
	sta	mnemo
;
;	get operands
;
	lxi	h,opnd1
	lxi	d,opnd1+1
	lxi	b,15			; clear operand 1 & 2
	mvi	m,0
	ldir
	call	skipsp
	call	testch
	jrz	getopndend		; ready if no first operand
	lxiy	opnd1
	mvi	b,0
	call	analopnd		; analyse first operand
	call	skipsep
	call	testch
	jrz	getopndend		; ready if no second operand
	lxiy	opnd2
	mvi	b,1
	call	analopnd		; analyse second operand
	call	testch
	jnz	cmderr			; error if something else
;
getopndend:
	lxix	opnd1
	lxiy	opnd2
	ldx	a,0
	ora	a			; prefix for operand 1 ?
	jrz	getopnden10
	ldy	a,0
	ora	a
	jrz	getopnden10
	cmpx	0
	jnz	cmderr			; error if prefix <> in both operands
getopnden10:
;
;	translate the opcode
;
	lda	mnemo
	call	translate
	jc	cmderr
;
;	store
;
	IF	extended
	lhld	caddress
	pop	psw
	call	peek
	lxi	h,string
	lxi	d,peekbuf
	ELSE
	lxi	h,string
	lded	caddress
	ENDIF
	mov	c,b
	mvi	b,0
	IF	extended
	push	b
	ENDIF
	ldir
	IF	extended
	call	poke
	lhld	caddress
	pop	b
	dad	b
	ELSE
	xchg
	ENDIF
	ret
;
;
;	analopnd:	analyse operand
;
;	For some inputs, three alternative interpretations are possible.
;	For example, C could be either an 8-bit constant or the register C
;	or the condition code.
;	Each operand description thus provides three fields, where
;	the first is used for a register description if possible, the
;	second for a constant description, and the third for a condition code.
;
;	operand description:
;
;		0:	IX/IY-prefix (DD/FD) or 0
;		1:	register number
;			1x: 8-bit
;			2x: 16-bit
;			3x: (16-bit)
;			90: (C)
;			B0: AF'
;		2:	Offset marker: offset present if <> 0
;		3:	8-bit offset
;		4:	value marker
;			50: immediate 16-bit
;			A0: (immediate 16-bit)
;		5,6:	value
;		7:	condition code (8x)
;
analopnd:
	mvi	c,0
	call	testch
	cpi	'('
	jrnz	anal10		; ok if no (
	mov	c,a		; else mark it
	inxix			; and skip
	jr	anal20		; cant be condition code
;	
;	check for condition code
;
anal10:
	mov	a,b
	ora	a
	jrnz	anal20		; cant be condition code if second operand
	pushix
	call	getch
	call	isletter
	jrc	anal19		; no cc if not a letter
	mov	e,a
	mvi	d,' '
	call	getch		; next
	jrz	anal15
	cpi	','		; ready if terminator
	jrz	anal15
	call	isletter	; else must be a letter
	jrc	anal19
	mov	d,a
	call	terminal	; and a terminator
	jrnz	anal19		; no cc if not
anal15:
	lxix	ccnam		; condition code names
	push	b
	mvi	b,8		; 8 condition names
	mvi	c,0
anal16:
	ldx	l,0
	ldx	h,1
	ora	a
	dsbc	d		; compare
	jrz	anal17		; branch on match
	inxix
	inxix
	inr	c
	djnz	anal16
	pop	b		; no match, not a cc
	jr	anal19
;
anal17:
	mvi	a,80h		; condition code marker
	ora	c		; plus code
	sty	a,7		; store
	pop	b
;
anal19:
	popix			; back to the start
;
anal20:
	pushix
	push	b
	call	rdregister	; try to read register
	pop	b
	jc	noregister	; branch if no register
	cpi	80h
	jrc	analreg10	; branch if not alternate reg
	cpi	0a4h		; must be alternate AF
	jnz	noregister
	mov	a,b
	ora	a		; second operand ?
	jz	noregister	; not allowed as first
	mov	a,c
	ora	a
	jnz	noregister	; not allowed as ()
	mviy	0b0h,1		; mark AF
	call	terminal
	jnz	noregister
	pop	h		; discard old IX
	ret
;
;
analreg10:
	cpi	30h
	jnc	noregister	; variables are no registers here
	cpi	20h
	jc	reg8bit		; branch for 8-bit register
	cpi	27h
	jnc	noregister	; PC not allowed
	cpi	24h		; AF ?
	jrnz	analreg15
	mov	a,b
	ora	a
	jnz	noregister	; AF cant be second operand
	mvi	a,24h		; restore reg-code
analreg15:
	sty	a,1		; store register code
	cpi	25h		; IX/IY ?
	jrc	analreg20
	mviy	22h,1		; change reg to HL
	mvi	a,0ddh		; IX-prefix
	jrz	analreg19	; ok if IX
	mvi	a,0fdh
analreg19:
	sty	a,0
analreg20:
	mov	a,c
	ora	a
	jrz	isregister	; ready if no (
	sety	4,1		; change 2xh to 3xh
	call	testch
	cpi	')'
	jrnz	regoffset
	inxix			; skip ')'
	jr	isregister
;
regoffset:
	ldx	a,0		; prefix
	ora	a		; IX/IY ?
	jrz	noregister	; cant be a register if not
	call	expression	; get offset
	jc	cmderr
	mviy	40h,2		; mark offset follows
	sty	l,3		; store offset
	pop	h		; discard old IX
	call	getch
	cpi	')'
	jnz	cmderr
	call	terminal
	jnz	cmderr
	ret			; can be nothing else but IX/IY +/- offset
;
;
isregister:
	call	terminal
	jrnz	noregister	; cant be register if something follows
	xtix			; restore old IX, save new one
	call	expression
	jrnc	exprtoo		; branch if it could also be an expression
isreg20:
	popix			; restore our IX
	ora	a
	ret
;
exprtoo:
	mov	a,c
	ora	a
	jrz	exprtoo10	; branch if no (
	call	getch
	cpi	')'
	jrnz	isreg20		; not an expression if terminating ) missing
	jr	exprtoo20
exprtoo10:
	mov	a,b
	ora	a		; first operand ?
	jrz	isreg20		; no non-bracketed constant as first operand
exprtoo20:
	call	terminal
	jrnz	isreg20		; no expression if something follows
	pop	d		; discard IX
	jr	isexpression
;
noregister:
	xra	a
	sty	a,0		; clear prefix
	sty	a,1		; and reg-opnd
	sty	a,2
	popix			; back to old pointer
	call	expression
	jrnc	noreg10
	ldy	a,7		; condition code ?
	ora	a
	jz	cmderr		; error if neither reg nor expression nor cc
noreg05:
	call	getch
	rz
	cpi	','
	rz
	jr	noreg05		; skip to terminator for condition code
;
noreg10:
	mov	a,c
	ora	a
	jrz	noreg20
	call	getch
	cpi	')'
	jnz	cmderr
noreg20:
	call	terminal
	jnz	cmderr		; error if not last
isexpression:
	sty	l,5
	sty	h,6
	mviy	50h,4
	mov	a,c
	ora	a
	rz
	mviy	0a0h,4
	ret
;
reg8bit:
	cpi	19h
	jrnc	noregister	; F/IFF not allowed here
	sty	a,1		; store register number
	mov	a,c
	ora	a
	ldy	a,1		; register number again
	jrz	is8reg		; ok if no (
	cpi	11h		; C ?
	jrnz	noregister
	call	getch
	cpi	')'
	jrnz	noregister
	mviy	90h,1		; replace (C)
	jmp	isregister
;
is8reg:
	cpi	17h		; R ?
	jnz	isregister
	pop	h		; cant be expression if R
	call	terminal
	jnz	cmderr
	ora	a
	ret
;
;
terminal:
	call	skipsp
	call	testch
	rz
	cpi	','
	ret
;
;------------------------------------------------------------------------------
;
	dseg
;
mnemo	ds	1
opnd1	ds	8
opnd2	ds	8
;
	end

