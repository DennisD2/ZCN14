	title	'Starter for WADE'
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
;
monstart:
	lxi	sp,stack
;
	IF	NOT cpm3
	call	prlmove
	ENDIF
;
	lxi	d,signon
	mvi	c,9
	call	5
;
	lhld	6		; start location
	mov	a,h
	rrc
	rrc
	rrc
	rrc
	call	hexdig
	sta	protadr
	mov	a,h
	call	hexdig
	sta	protadr+1
;
	lxi	d,initpar
	mvi	c,60
	call	5
;
nomonerr:
	lxi	d,monerr
	mvi	c,9
	call	5
	jmp	0
;
hexdig:
	ani	0fh
	adi	'0'
	cpi	'9'+1
	rc
	adi	'A'-'0'-10
	ret
;
;
signon	db	'WADE 1.5 - Wagner 85-04-27  '
	IF	cpm3
	db	'(CP/M 3 Version'
	ELSE
	db	'(TurboDos & CP/M 2 Version'
	ENDIF
	IF	extended
	db	', Extended Adressing'
	IF	mega
	db	' [Mega]'
	ENDIF
	ENDIF
	db	')',0dh,0ah,'$'
;
monerr	db	'ERROR, WADE-RSX not present',0dh,0ah,'$'
;
initpar:
	db	0,0
	dw	protstr
;
protstr	db	'RPC >= '
protadr	db	'0000',0
;
;
	IF	NOT cpm3
;
monname	db	'MONIT   '
;
prlmove:
	lxi	h,pgmend+100h+16	; end of this program + PRL-header
	lxi	b,300h			; max number of bytes to search
;
prlsearch:
	push	h
	push	b
	lxi	d,monname
	mvi	b,8
prlcomp:
	ldax	d
	cmp	m
	jrnz	notfound
	inx	d
	inx	h
	djnz	prlcomp
	pop	b
	pop	h		; we have the address
	jr	moveprl
;
notfound:
	pop	b
	pop	h
	inx	h
	dcx	b
	mov	a,b
	ora	c
	jrnz	prlsearch
	jmp	nomonerr
;
moveprl:
	lxi	d,100h+16
	ora	a
	dsbc	d		; PRL header starts at RSX-name field - 110h
;
	push	h
	inx	h
	mov	c,m
	inx	h
	mov	b,m		; program size
	inx	h
	inx	h
	mov	e,m
	inx	h
	mov	d,m		; additional memory
	xchg
	dad	b		; program size + addtl mem
	lda	7		; high byte of bdos-addr
	dcr	a		; 100h less to be safe
	sub	h		; subtract total program length
	mov	d,a
	mvi	e,0
	pop	h		; PRL-file start
	push	b		; save program size
	push	d		; start of program
	lxi	d,100h
	dad	d		; point after PRL-header
	pop	d
	push	d
;
	ldir			; move program into correct location
;
	pop	d		; start of program
	pop	b		; program size
	push	d		; save program start again
	push	h		; save bitmap addr
	mov	h,d		; high byte of prog start = offset
	dcr	h		; - 100h
;
relocloop:
	mov	a,b
	ora	c
	jz	reldone		; ready if all bytes relocated
	dcx	b
	mov	a,e
	ani	7		; new byte ?
	jnz	samebyte
	xthl
	mov	a,m		; get next reloc byte
	inx	h
	xthl
	mov	l,a
samebyte:
	mov	a,l
	ral
	mov	l,a
	jnc	nooff		; no offset if bit clear
	ldax	d
	add	h		; else add offset
	stax	d
nooff:
	inx	d
	jmp	relocloop
;
reldone:
	pop	d
	pop	h	; program start
	mvi	l,6
	lded	6	; get old BDOS entry
	shld	6	; set new BDOS entry
	lxi	b,4
	dad	b	; point to "next" address in RSX-Header
	mov	m,e	; store old BDOS addr at "next" in RSX-Header
	inx	h
	mov	m,d
	ret
;
	ENDIF
;
pgmend:
stack	equ	pgmend+100h
;
	end	monstart

