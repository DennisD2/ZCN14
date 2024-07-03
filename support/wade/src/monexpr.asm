	title	'Expression evaluation for Monitor'
;
;	Last Edited	85-04-05	Wagner
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
;
	public	expression,mexpression,sexpression
;
	IF	symbolic
	extrn	rdsymbol
	ENDIF
	extrn	rdregval,rdword,rdstrword
	extrn	getch,testch,skipsp,skipsep
	extrn	mul16,div16
	extrn	cmderr
;
	IF	extended
	extrn	peek,poke,peekbuf,cbank,bankok,xltbank
	ENDIF
;
;------------------------------------------------------------------------------
;
;	mexpression:	process multiple expressions, return value of last
;
mexpression:
	call	expression
	rc			; ret with carry if none
mexploop:
	push	h
	push	psw
	call	sexpression
	jrc	mexpend		; ready if no more expressions
	pop	d
	pop	d		; discard old expression
	jr	mexploop
;
mexpend:
	pop	psw
	pop	h		; restore expression
	ora	a		; clear carry
	ret
;
;
;
;	expression:	read expression, return word value
;	sexpression:	call skipsep first, then expression
;
;		exit:	HL = value
;			A = bank (CBANK if none specified)
;			Carry set if no value
;
;		uses:	-
;
;
sexpression:
	call	skipsep
;
expression:
	push	b
	push	d
	pushiy
	call	bexpression
	popiy
	pop	d
	mov	a,b
	pop	b
	ret
;
;------------------------------------------------------------------------------
;
;	For all following expression subroutines, the following general
;	register usage holds:
;
;		HL contains the result 
;		C  contains the factor descriptor (0 means 16-Bit variable
;		   or no variable)
;		DE contains a variable address if the factor is a variable
;		   or register, otherwise zero
;
;		additionally, EXTEXPRESSION returns the extended address byte
;		in register B.
;
;
bexpression:
	call	extexpression		; first factor
	rc				; exit if no value
;
	push	b
	push	d
	lxiy	assexpoptab
	call	isop
	jrz	assexit			; ready if end of string/expression
	call	bexpression		; get next operand
	jc	cmderr			; error if operator without operand
	ret				; enter handler by returning
;
assexit:
	pop	d			; restore first operand address
	pop	b
	ret
;
;
assexpoptab:
	db	':='
	dw	opwassign
	db	'=='
	dw	opassign
	db	0
;
;
opassign:
	popiy				; first operand value
	pop	d			; first operand address
	pop	b			; first operand descriptor
	pushiy				; value back on the stack
	mov	a,d			; variable address present ?
	ora	e
	jrnz	assreg			; assign to var if yes
	pop	d			; else assign byte to address
	IF	extended
	xchg
	mov	a,b
	call	peek
	mov	a,e
	sta	peekbuf
	call	poke
	xchg
	ELSE
	mov	a,l
	stax	d
	ENDIF
	mvi	h,0
assret:
	lxi	d,0
	IF	extended
	lda	cbank
	mov	b,a
	ENDIF
	ret
;
assreg:
	pop	psw			; discard first operand value
	mov	a,l
	stax	d			; store 8-bit value into DE
	mov	a,c
	ora	a			; 16-bit register ?
	jrz	asswordreg		; then assign 16-bit
	mvi	h,0
	jr	assret
;
asswordreg:
	inx	d
	mov	a,h
	stax	d
	jr	assret
;
opwassign:
	popiy				; first operand value
	pop	d			; first operand address
	pop	b			; first operand descriptor
	pushiy				; value back on the stack
	mov	a,e			; variable address present ?
	ora	d
	jrnz	assreg			; assign to variable if yes
	pop	d			; else assign word to address
	IF	extended
	xchg
	mov	a,b
	call	peek
	sded	peekbuf
	call	poke
	xchg
	ELSE
	mov	a,l
	stax	d
	inx	d
	mov	a,h
	stax	d
	ENDIF
	jr	assret
;
;------------------------------------------------------------------------------
;
extexpression:
	IF	extended
;
	call	boolexpression		; first factor
	lda	cbank			; init bank
	mov	b,a
	rc
;
	lxiy	extexpoptab
	call	isop
	rz
	call	boolexpression		; get next operand
	jc	cmderr			; error if operator without operand
	call	execop			; execute operation
	ret
;
extexpoptab:
	db	':',0
	dw	opextaddr
	db	0
;
opextaddr:
	xchg				; Result: HL = Operand 2
	mov	b,e			; 	  B = Operand 1 (low byte)
	lxi	d,0
	ret
;
	ENDIF
;
;------------------------------------------------------------------------------
;
boolexpression:
	call	simpleexpression	; first factor
	rc				; exit if no value
;
boolexploop:
	lxiy	boolexpoptab
	call	isop
	rz				; ready if end of string/expression
	call	simpleexpression	; get next operand
	jc	cmderr			; error if operator without operand
	call	execop			; execute operation
	jr	boolexploop
;
boolexpoptab:
	db	'&&'
	dw	opbooland
	db	'||'
	dw	opboolor
	db	'!!'
	dw	opboolor
	db	0
;
;
opbooland:
	call	makebool
	mov	a,h
	ana	d
	mov	h,a
	mov	l,a
	ret
;
opboolor:
	call	makebool
	mov	a,h
	ora	d
	mov	h,a
	mov	l,a
	ret
;
makebool:
	call	setbits
	xchg
setbits:
	mov	a,h
	ora	l
	rz
	mvi	h,0ffh
	mov	l,h
	ret
;
;------------------------------------------------------------------------------
;
simpleexpression:
	call	compexpression		; first factor
	rc				; exit if no value
;
simpexploop:
	lxiy	simpexpoptab
	call	isop
	rz				; ready if end of string/expression
	call	compexpression		; get next operand
	jc	cmderr			; error if operator without operand
	call	execop			; execute operation
	jr	simpexploop
;
simpexpoptab:
	db	'<='
	dw	opltoreq
	db	'>='
	dw	opgtoreq
	db	'<>'
	dw	opnoteq
	db	'=',0
	dw	opeq
	db	'>',0
	dw	opgt
	db	'<',0
	dw	oplt
	db	0
;
;
oplt:
	dsbc	d
	jr	cmpresult
;
opgt
	xchg
	jr	oplt
;
opgtoreq:
	dsbc	d
	cmc
	jr	cmpresult
;
opltoreq:
	xchg
	jr	opgtoreq
;
cmpresult:
	jrc	cmprestrue
	jr	cmpresfalse
;
opeq:
	dsbc	d
	jrz	cmprestrue
cmpresfalse:
	lxi	h,0
	ret
;
opnoteq:
	dsbc	d
	jrz	cmpresfalse
cmprestrue:
	lxi	h,0ffffh
	ret
;
;------------------------------------------------------------------------------
;
compexpression:
	call	mulexpression		; first factor
	rc				; exit if no value
;
compexploop:
	lxiy	compexpoptab
	call	isop
	rz				; ready if end of string/expression
	call	mulexpression		; get next operand
	jc	cmderr			; error if operator without operand
	call	execop			; execute operation
	jr	compexploop
;
compexpoptab:
	db	'-',0
	dw	opminus
	db	'+',0
	dw	opplus
	db	0
;
;
opminus:
	dsbc	d
	ret
;
opplus:
	dad	d
	ret
;
;------------------------------------------------------------------------------
;
;
mulexpression:
	call	logexpression		; first factor
	rc				; exit if no value
;
mulexploop:
	lxiy	mulexpoptab
	call	isop
	rz				; ready if end of string/expression
	call	logexpression		; get next operand
	jc	cmderr			; error if operator without operand
	call	execop			; execute operation
	jr	mulexploop
;
mulexpoptab:
	db	'<<'
	dw	opshl
	db	'>>'
	dw	opshr
	db	'*',0
	dw	opmul
	db	'/',0
	dw	opdiv
	db	'%',0
	dw	opmod
	db	0
;
opshl:
	mov	a,d
	ora	a
	jnz	cmderr
	mov	b,e
	ora	b
	rz
expshll:
	mov	a,h
	rlc
	ralr	l
	ralr	h
	djnz	expshll
	ret
;
opshr:
	mov	a,d
	ora	a
	jnz	cmderr
	mov	b,e
	ora	b
	rz	
expshrl:
	mov	a,l
	rrc
	rarr	h
	rarr	l
	djnz	expshrl
	ret
;
opmul:
	call	mul16
	ret
;
opdiv:
	call	div16
	ret
;
opmod:
	call	div16
	xchg			; remainder into HL
	ret
;
;------------------------------------------------------------------------------
;
logexpression:
	call	factor			; first factor
	rc				; exit if no value
;
logexploop:
	lxiy	logexpoptab
	call	isop
	rz				; ready if end of string/expression
	call	factor			; get next operand
	jc	cmderr			; error if operator without operand
	call	execop			; execute operation
	jr	logexploop
;
logexpoptab:
	db	'&',0
	dw	opand
	db	'!',0
	dw	opor
	db	'|',0
	dw	opor
	db	'#',0
	dw	opexor
	db	'^',0
	dw	opexor
	db	0
;
opand:
	mov	a,h
	ana	d
	mov	h,a
	mov	a,l
	ana	e
	mov	l,a
	ret
;
opor:
	mov	a,h
	ora	d
	mov	h,a
	mov	a,l
	ora	e
	mov	l,a
	ret
;
opexor:
	mov	a,h
	xra	d
	mov	h,a
	mov	a,l
	xra	e
	mov	l,a
	ret
;
;------------------------------------------------------------------------------
;
factor:
	lxi	d,0
	call	skipsp
	stc
	rz				; exit if no sign/value
	cpi	'+'
	jrz	issign
	cpi	'-'
	jrz	issign
	cpi	'~'
	jrnz	nosign
issign:
	push	psw
	inxix			; skip sign
	call	skipsp
	jz	cmderr		; sign only is an error
	pop	psw
nosign:
	push	psw		; save sign
	call	testch
	cpi	'('
	jrnz	noexprval
	inxix
	call	bexpression	; get expression value
	call	skipsp
	call	getch
	cpi	')'
	jnz	cmderr
	IF	extended
	lxi	d,0
	mov	a,b
	call	peek
	lhld	peekbuf
	mvi	h,0
	call	testch
	cpi	'.'
	jrnz	factready
	inxix
	lhld	peekbuf
	ELSE
	mov	e,m
	mvi	d,0
	call	testch
	cpi	'.'
	jrnz	factexp1
	inxix
	inx	h
	mov	d,m
factexp1:
	xchg
	lxi	d,0
	ENDIF
	jr	factready
;
noexprval:
	cpi	'['
	jrnz	nofactexpr
	inxix
	call	bexpression
	call	skipsp
	call	getch
	cpi	']'
	jnz	cmderr
	lxi	d,0
	jr	factready
;
nofactexpr:
	call	number
	jrc	nonumber
;
factready:
	pop	psw		; restore sign
	jrnz	factexit	; ret if no sign
	cpi	'+'
	jrz	factplus	; ret if plus
	cpi	'-'
	jrnz	factcpl
	xchg
	lxi	h,0
	dsbc	d		; 0 - val -> negation
factplus:
	lxi	d,0
factexit:
	ora	a		; clear carry
	ret
;
factcpl:
	mov	a,h
	cma
	mov	h,a
	mov	a,l
	cma
	mov	l,a
	jr	factplus
;
nonumber:
	pop	psw
	jz	cmderr		; lonely sign
	stc
	ret
;
;
;------------------------------------------------------------------------------
;
;	isop:	check if input is an operator
;
;		entry:	IY = table address
;
;		exit:	Zero-Flag set if not an operator
;			then: DE and HL are left untouched
;
;			Zero-Flag clear if operator
;			then:  	(SP) = Operator handler routine addr
;				(SP+2) = HL
;				DE = 0
;
isop:
	xthl			; save HL
	push	h		; save retaddr
	call	skipsp
	jrz	isnotanop	; not an operator if end of input
isoploop:
	ldy	a,0		; get first char of operator
	ora	a
	jrz	isnotanop	; not an operator if at end of list
	cmpx	0		; compare with first input char
	jrnz	isopnext	; next list entry if not equal
	ldy	a,1		; next char of operator
	ora	a
	jrnz	isopcnext	; compare with next if two-char operator
	ldx	a,1		; next char from input line
	cpi	'='		; compare with possible second char ops
	jrz	isopnext	; and go to next table entry if it is one
	cpi	'>'
	jrz	isopnext
	cpi	'<'
	jrz	isopnext
	cpi	'&'
	jrz	isopnext
	cpi	'!'
	jrz	isopnext
	cpi	'|'
	jrz	isopnext
	jr	isanop
;
isopcnext:
	cmpx	1
	jrnz	isopnext
	inxix			; skip two characters
;
isanop:
	inxix			; skip operator character
	ldy	l,2		; get handler routine addr
	ldy	h,3
	xthl			; put on the stack
	ori	0ffh		; set nonzero to mark operator found
	lxi	d,0		; clear var addr
	pchl			; and return
;
isnotanop:
	pop	h		; retaddr
	xthl			; HL
	xra	a		; clear A
	ret
;
isopnext:
	inxiy
	inxiy
	inxiy
	inxiy
	jr	isoploop
;
;
;	execop:	execute operator
;
;		entry:	HL = second operand
;			(SP+2) = handler address
;			(SP+4) = HL of first operand
;
;		exit:	HL = result
;
execop:
	xchg		; HL 2 -> DE
	pop	h	; retaddr
	popiy		; handler
	xthl		; HL 1
	ora	a	; clear carry
	pciy		; go to handler
;
;------------------------------------------------------------------------------
;
number:
	IF	symbolic
	call	rdsymbol		; try symbol name
	lxi	d,0
	rnc
	ENDIF
	call	rdregval		; try register name
	rnc				; ready if register
	call	rdword			; read value
	lxi	d,0
	rnc				; ready if present
	call	rdstrword		; else try string word
	lxi	d,0
	ret
;
	end
