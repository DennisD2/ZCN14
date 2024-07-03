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
	public	symstart,symtop
;
	extrn	cmderr,next
	extrn	wrchar,wrhex,space,space2,crlf,wrstr
	extrn	stestch,sgetch,isdigit,isletter
	extrn	regsp,maxval,topval
	extrn	puthexbyte,putfilch
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
;	symtop	 -->	|  last symbol
;			|  ...
;			|  free space
;			-----------------------------  low mem
;	currsx	 -->	|  RSX-header (page aligned)
;			-----------------------------
;			|  default stack
;			|  ...
;			-----------------------------
;	maxval	 -->	|  top of program
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
	lhld	symtop
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
	lhld	symtop
	xra	a
	dsbc	d
	jrz	symsrchfnd
	dcx	d
	dcx	d
	lhld	symtop
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
	lbcd	symtop
	ora	a
	dsbc	b		; already in the table ?
	pop	h
	jrz	defsym01	; ok if not
;
	push	h
	lded	symtop
	lxi	b,symlen+2
	lddr			; move to symtop
	sded	symtop		; temporarily set new symtop
	pop	h
	call	killsymbol	; delete at old place
	lhld	symtop
	lxi	d,symlen+2
	dad	d
	shld	symtop		; reset symtop to previous value
	mov	b,h
	mov	c,l
;
defsym01:
	lxi	d,3*(symlen+2)+26	; safety margin
	lhld	currsx		; bottom of symbol memory
	dad	d		; + safety
	ora	a
	dsbc	b		; - symtop
	cnc	expand		; expand if (currsx + margin) >= symtop
;
	pop	h		; address value into HL
	call	findaddr	; find the value
	xchg
	lhld	symtop
	ora	a
	dsbc	d
	jrnz	defsym10	; branch if not at top
	lxi	h,-(symlen+2)
	dad	d
	shld	symtop		; set new top
	ret
;
defsym10:
	push	d		; save elem addr
	lhld	symtop
	lxi	b,-(symlen+2)
	dad	b		; new symtop
	shld	symtop
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
	lhld	symtop		; new symtop contains new elem
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
	lhld	symtop
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
	lded	symtop
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
	lhld	symtop
	lxi	d,symlen+2
	dad	d
	shld	symtop
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
	lded	symtop
	ora	a
	dsbc	d			; used space
	lxi	d,symlen+2
	call	div16
	mvi	a,' '
	call	wrdec
	call	space2
	lxi	h,freestr
	call	wrstr
	lhld	symtop
	lded	currsx
	ora	a
	dsbc	d
	lxi	d,-(3*(symlen+2)+26)
	dad	d
	lxi	d,symlen+2
	call	div16
	mvi	a,' '
	call	wrdec
	call	crlf
	call	crlf
;
	lhld	symstart
dissymlin:
	mvi	b,80/(symlen+7)
dissymloop:
	xchg
	lhld	symtop
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
freestr	db	'Free: ',0
;
;
;	wsymbols:	write symbol table to file
;
;
wsymbols:
	lhld	symstart
fwsymline:
	mvi	b,4
fwsymloop:
	xchg
	lhld	symtop
	ora	a
	dsbc	d
	xchg
	jrz	fwsymend
	push	b
	push	h
	mov	a,m
	call	puthexbyte
	pop	h
	dcx	h
	mov	a,m
	push	h
	call	puthexbyte
	mvi	a,' '
	call	putfilch
	pop	h
	dcx	h
	mvi	b,symlen
fwsym10:
	mov	a,m
	cpi	' '
	jrz	fwsym20
	push	b
	push	h
	call	putfilch
	pop	h
	pop	b
	dcx	h
	djnz	fwsym10
	jr	fwsym30
;
fwsym20:
	dcx	h
	djnz	fwsym20
fwsym30:
	pop	b
	dcr	b
	jrz	fwsym40
	push	b
	push	h
	mvi	a,09h
	call	putfilch
	pop	h
	pop	b
	jr	fwsymloop
;
fwsym40:
	push	h
	mvi	a,0dh
	call	putfilch
	mvi	a,0ah
	call	putfilch
	pop	h
	jr	fwsymline
;
;
fwsymend:
	mov	a,b
	cpi	4
	rz
	jr	fwsym40
;
;
;
;	expand:		expand symbol table by default size
;
;		entry:	-
;
;
;	rsvsym:		reserve symbol table space
;
;		entry:	HL = number of symbols to reserve
;
rsvsym:
	lxi	d,symlen+2
	call	mul16		; required symbol table space
	lxi	d,0ffh
	dad	d
	mvi	l,0		; round to next page boundary
	jr	expand10
;
expand:
	lxi	h,512
;
expand10:
	push	h
	lxi	d,512
	dad	d
	lded	maxval		; max addr read until now
	dad	d		; max + sym-space + 512 bytes for safety
	xchg
	lhld	currsx
	ora	a
	dsbc	d		; currsx - (max + n)
	jc	cmderr		; error if max > curr
;
	pop	d
	lxi	h,0
	dsbc	d		; complement symbol table space
	push	h
	lded	regsp		; current stack ptr
	lhld	currsx		; RSX base
	ora	a
	dsbc	d		; stack length
	jrc	setstack	; no stack copying if SP > RSX
	jrz	setstack	; no copying if equal
	mov	a,h
	cpi	2
	jrnc	copyrsx		; no stack copying if difference >= 512
	mov	b,h
	mov	c,l		; save length
	pop	h
	push	h
	dad	d		; SP - space
	xchg			; copy from SP to (SP-space)
	ldir			; move down the stack
;
setstack:
	lhld	regsp
	pop	d
	push	d
	dad	d		; SP - space
	shld	regsp		; set new SP
;
copyrsx:
	lded	currsx		; current RSX header
	pop	h
	dad	d		; - space
	shld	currsx		; new RSX header
	dcx	h
	shld	topval
	inx	h
	xchg			; move from old RSX to (RSX-space)
	push	d
	lxi	b,26
	ldir			; move down the RSX header
	pop	h
	lxi	d,6
	dad	d		; new BDOS entry in RSX header
	shld	6		; set jump location
;
	IF	cpm3
	xchg			; save new RSX entry address
	lxi	h,4
	dad	d		; next field
	push	d
	mov	e,m
	inx	h
	mov	d,m		; addr of next RSX
	lxi	h,6
	dad	d		; point to prev-field in next RSX
	pop	d
	mov	m,e		; set prev-field
	inx	h
	mov	m,d
	sded	mxtpa
	lxi	d,scbpb
	mvi	c,49		; set scb
	jmp	next		; set new MXTPA field
;
scbpb	db	62h		; MXTPA offset
	db	0feh		; set word value
mxtpa	dw	0
;
	ELSE
;
	ret
;
	ENDIF
;
;
;
;	syminit:	initialise symbol space
;
;		entry:	HL = RSX base
;
syminit:
	shld	currsx
	inx	h
	shld	symtop
	shld	symstart
	jmp	expand
;
;
	dseg
;
currsx		ds	2
symtop		ds	2
symstart	ds	2
;
	end

