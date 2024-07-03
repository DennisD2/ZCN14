	title	'Symbol Handler for Monitor'
;
;	Last Edited	84-07-03	Wagner
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
	public	rdsymbol,rdsymname,defsymbol,killsymbol,dissymbols,wrsymbol
	public	syminit,wsymbols,rsvsym
	public	symstart

	public	readsym
	public	sfile
;
	extrn	cmderr
	extrn	wrchar,wrhex,space,space2,crlf,wrstr
	extrn	stestch,sgetch,isdigit,isletter
	extrn	regsp,maxval,topval
	extrn	mul16,div16,wrdec
;
;
;
	maclib	z80
	maclib	monopt
;
;
symlen	equ	8
;
;
;
; Symbol Storage:
;
;			|	debugger
;			---------------------------   high mem
;	symstart  -->	|  Symbols: Top down
;			|  N  }
;			|  A  }
;			|  M  }} "symlen" bytes per name
;			|  E  }
;			|  addr hi
;			|  addr lo
;			|  ...
;			|  ...
;	topval	 -->	|  last symbol
;			-----------------------------  low mem
;
;
;------------------------------------------------------------------------------
;
;	rdsymbol:	read symbol value
;
;		exit:	HL = symbol value
;			Carry set if not a symbol or if symbol is undefined
;
rdsymbol:
	cpi	'.'
	stc
	rnz			; ret if no symbol lead-in
	pushix
	call	sgetch
	call	rdsymname
	jrc	rdsym10
	jrnz	rdsym20
	stc
rdsym10:
	popix
	ret
;
rdsym20:
	pop	d
	mov	d,m
	dcx	h
	mov	e,m
	xchg
	ret
;
;
;	rdsymname:	read symbol name
;
;		exit:	HL = symbol table pointer
;			carry set if no symbol name found
;			A = 0 if new (undefined) symbol
;
rdsymname:
	call	stestch
	call	isdigit
	cmc
	rc			; no symbol if first is digit
	call	issymch
	rc
;
	lhld	topval
	dcx	h
	dcx	h
	mvi	b,symlen
;
rdsymn10:
	call	sgetch
	dcr	b
	inr	b
	jrz	rdsymn15
	mov	m,a
	dcx	h
	dcr	b
rdsymn15:
	call	stestch
	call	issymch
	jrnc	rdsymn10
;
	inr	b
rdsymn20:
	mvi	m,' '
	dcx	h
	djnz	rdsymn20
;
;	symbol read, now search in table
;
	lded	symstart
symsrch:
	lhld	topval
	xra	a
	dsbc	d
	jrz	symsrchfnd
	dcx	d
	dcx	d
	lhld	topval
	mvi	b,symlen
	dcx	h
	dcx	h
symcmp:
	ldax	d
	cmp	m
	jrnz	symnomatch
	dcx	h
	dcx	d
	djnz	symcmp
	mvi	a,0ffh			; signal exists
;
	lxi	h,symlen+2
	dad	d
	ora	a
	ret
;
symsrchfnd:
	xchg
	ret
;
symnomatch:
	dcx	d
	djnz	symnomatch
	jr	symsrch
;
;
issymch:
	ora	a
	stc
	rz
	call	isletter
	rnc
	call	isdigit
	rnc
	push	h
	push	b
	lxi	h,symchtab
	lxi	b,lsymchtab
	ccir
	pop	b
	pop	h
	stc
	rnz
	ora	a
	ret
;
symchtab	db	'?@$.'
lsymchtab	equ	$-symchtab
;
;
;------------------------------------------------------------------------------
;
;	defsymbol:	define symbol
;
;		entry:	HL = name pointer
;			DE = address
;
defsymbol:
	push	d		; save address value
	mov	m,d
	dcx	h
	mov	m,e		; store value
	inx	h		; pointer again
	push	h
	lbcd	topval
	ora	a
	dsbc	b		; already in the table ?
	pop	h
	jrz	defsym01	; ok if not
;
	push	h
	lded	topval
	lxi	b,symlen+2
	lddr			; move to topval
	sded	topval		; temporarily set new topval
	pop	h
	call	killsymbol	; delete at old place
	lhld	topval
	lxi	d,symlen+2
	dad	d
	shld	topval		; reset topval to previous value
	mov	b,h
	mov	c,l
;
defsym01:
	pop	h		; address value into HL
	call	findaddr	; find the value
	xchg
	lhld	topval
	ora	a
	dsbc	d
	jrnz	defsym10	; branch if not at top
	lxi	h,-(symlen+2)
	dad	d
	shld	topval		; set new top
	ret
;
defsym10:
	push	d		; save elem addr
	lhld	topval
	lxi	b,-(symlen+2)
	dad	b		; new topval
	shld	topval
	xchg
	ora	a
	dsbc	d		; element addr - new top = length to move
	mov	b,h		; length into BC
	mov	c,l
	lxi	h,-(symlen+2)
	dad	d		; move destination = new top - symlen+2
	xchg
	inx	b		; one byte more
	ldir			; make space for new elem
	pop	d		; elem addr
	lhld	topval		; new topval contains new elem
	lxi	b,symlen+2
	lddr			; move into place
	ret
;
;
;	findaddr:	find symbol corresponding to "addr"
;
;		entry:	HL = address
;
;		exit:	HL = symbol pointer
;			Carry set if not found
;
findaddr:
	mov	b,h
	mov	c,l
	lhld	symstart
findcmp:
	xchg
	lhld	topval
	ora	a
	dsbc	d
	xchg
	stc
	rz			; ret if end of table
	mov	d,m
	dcx	h
	mov	e,m
	inx	h
	ora	a
	xchg
	dsbc	b		; elem-addr - addr
	xchg
	jrc	findcmp10
	rz
	stc
	ret			; ret on match or elem-addr > addr
findcmp10:
	lxi	d,-(symlen+2)
	dad	d
	jr	findcmp
;
;
;	killsymbol:	delete symbol from the table
;
;		entry:	HL = symbol pointer
;
killsymbol:
	push	h
	lded	topval
	ora	a
	dsbc	d			; symptr - top = remaining length
	pop	d
	rz				; ret if at top
	mov	b,h
	mov	c,l
	mov	h,d
	mov	l,e
	push	d
	lxi	d,-(symlen+2)
	dad	d
	pop	d
	lddr
	lhld	topval
	lxi	d,symlen+2
	dad	d
	shld	topval
	ret
;
;
;	wrsymbol:	write symbol corresponding to "addr"
;
;		entry:	HL = address
;			A = display code:
;				0   -> display spaces only
;				'.' -> display '.name'
;				'/' -> display '/name'
;				':' -> display 'name:'
;
wrsymbol:
	ora	a
	jrz	wrspaces
	push	psw
	call	findaddr
	jrc	wrspaces2
	dcx	h
	dcx	h
	pop	psw
	cpi	':'
	cnz	wrchar		; display dot or slash
	jmp	writesym
;
;
wrspaces2:
	pop	psw
wrspaces:
	mvi	b,symlen+1
wrspa2:
	call	space
	djnz	wrspa2
	ret
;
;
writesym:
	mvi	b,symlen
	mov	c,a
writesym2:
	mov	a,m
	cpi	' '
	jrz	writesym3
	call	wrchar
	dcx	h
	djnz	writesym2
	mov	a,c
	cpi	':'
	rnz
	jmp	wrchar
;
writesym3:
	mov	a,c
	cpi	':'
	cz	wrchar
writesym4:
	call	space
	dcx	h
	djnz	writesym4
	ret
;
;
;	dissymbols:	display symbol table
;
;
dissymbols:
	lxi	h,defstr
	call	wrstr
	lhld	symstart
	lded	topval
	ora	a
	dsbc	d			; used space
	lxi	d,symlen+2
	call	div16
	mvi	a,' '
	call	wrdec
	call	crlf
;
	lhld	symstart
dissymlin:
	mvi	b,80/(symlen+7)
dissymloop:
	xchg
	lhld	topval
	ora	a
	dsbc	d
	xchg
	jz	crlf
	push	b
	mov	a,m
	call	wrhex
	dcx	h
	mov	a,m
	call	wrhex
	dcx	h
	call	space
	call	writesym
	call	space2
	pop	b
	djnz	dissymloop
	call	crlf
	jr	dissymlin
;
;
defstr	db	'Defined: ',0
;
;
;	wsymbols:	write symbol table to file
;
;
wsymbols:
rsvsym:
expand:
readsym:
sfile:
	ret
;
;	syminit:	initialise symbol space
;
syminit:
	lhld	topval
	shld	symstart
	ret
;
;
	dseg
;
symstart	ds	2
;
	end

