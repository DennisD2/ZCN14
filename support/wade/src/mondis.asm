	title	'Z80 Disassembler Module'
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
	public	disasm
;
	extrn	wrchar,wrhex,wrword,space,space2,wraddr
	IF	extended
	extrn	peek,peekbuf
	ENDIF
;
	extrn	analop
	extrn	mnemtab,r16nam,reg8nam,ccnam
	extrn	opdesc,jumpaddr
;
	IF	symbolic
	extrn	wrsymbol
	ENDIF
;
;
	cseg
;
;	disasm:		disassemble one opcode
;
;		entry:	A/HL = address
;			B  = opcode display on if <> 0
;
;		exit:	HL = next opcode address
;
;		uses:	all registers
;
;
;	On return, Jumpmark contains
;
;		00	No jump
;		10	Immediate 16-bit jump
;		20	To stack (return)
;		3x	To register x, x=2: HL, x=5: IX, x=6: IY
;	code OR 80	conditional jump
;
;
disasm:
	push	h
	push	psw
	mov	a,b
	sta	opdis
	pop	psw
	push	psw
	call	analop
	pop	psw
	xthl			; save new pc, get old address
	call	wraddr
	call	space2
	push	b		; save mnemo
	push	h
	lda	opdis
	ora	a
	jrz	disasnoop
	mvi	c,5		; total length
	IF	extended
	lxi	h,peekbuf	; analop already did the peeking
	ENDIF
disas10:
	mov	a,m
	inx	h
	call	wrhex		; display opcode in hex
	call	space
	dcr	c
	djnz	disas10
;
disas20:
	call	space
	call	space2		; fill with spaces
	dcr	c
	jrnz	disas20
	jr	disas21
;
disasnoop:
	IF	NOT symbolic
	call	space2
	ENDIF
disas21:
	pop	h
;
	IF	symbolic
	mvi	a,':'
	call	wrsymbol
	call	space2
	ENDIF
;
	pop	b		; restore mnemo
	lxi	h,mnemtab
	mvi	b,0
	dad	b
	dad	b
	dad	b
	dad	b		; pointer * 4
	mvi	b,4
disas26:
	mov	a,m
	call	wrchar		; write mnemonic
	inx	h
	djnz	disas26
	call	space2
;
	IF	symbolic
	xra	a
	sta	dissym
	ENDIF
	lxix	opdesc
	mvi	b,11			; character down counter
disas30:
	ldx	a,0
	ora	a
	jrz	disasend
	rrc
	rrc
	rrc
	rrc
	ani	0fh
	dcr	a
	add	a
	mov	e,a
	mvi	d,0
	lxi	h,disastab
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	xchg
	ldx	a,0
	call	ipchl
	inxix
	ldx	a,0
	ora	a
	jrz	disasend
	mvi	a,','
	call	wrc
	jr	disas30
;
disasend:
	pop	h
	IF	NOT symbolic
	lda	opdis
	ora	a
	jrz	disasready
	ENDIF
disasfill:
	call	space
	djnz	disasfill
disasready:
	IF	symbolic
	lda	dissym
	push	h
	lhld	symadr
	call	wrsymbol
	pop	h
	ENDIF
	ret
;
ipchl:	pchl
;
;
disastab:
	dw	dis8reg		; 1x
	dw	dis16reg	; 2x
	dw	dismemreg	; 3x
	dw	dis8imm		; 40
	dw	dis16imm	; 50
	dw	disbitnum	; 6x
	dw	dis16jp		; 70
	dw	disccode	; 8x
	dw	discreg		; 90
	dw	disaddr		; a0
	dw	disaf		; b0
	dw	dis8addr	; c0
	dw	dis8imm		; d0
;
;
dis8reg:
	lxi	h,reg8nam
	ani	0fh
	mov	e,a
	mvi	d,0
	dad	d
	mov	a,m
;
wrc:
	dcr	b
	jmp	wrchar
;
;
dis16reg:
	lxi	h,r16nam
dis2idx:
	ani	07h
	add	a
	mov	e,a
	mvi	d,0
	dad	d
dis2chr:
	mov	a,m
	call	wrc
	inx	h
	mov	a,m
	cpi	' '
	rz
	jr	wrc
;
disccode:
	lxi	h,ccnam
	jr	dis2idx
;
disaf:
	lxi	h,r16nam+8
	call	dis2chr
	mvi	a,27h		; '
	jr	wrc
;
discreg:
	call	open
	mvi	a,'C'
	call	wrc
close:
	mvi	a,')'
	jr	wrc
;
open:
	mvi	a,'('
	jr	wrc
;
;
dismemreg:
	call	open
	ldx	a,0
	call	dis16reg
	ldx	a,0
	ani	8
	jrz	close
;
;	display signed offset
;
	inxix
	ldx	a,0
	ora	a
	mvi	c,'+'
	jp	dismem10
	mvi	c,'-'
	neg
dismem10:
	push	psw
	mov	a,c
	call	wrc
	pop	psw
	call	wrh
	jr	close
;
dis8addr:
	call	open
	ldx	a,0
	call	dis8imm
	jr	close
;
dis8imm:
	inxix
	ldx	a,0
;
wrh:
	dcr	b
	dcr	b
	jmp	wrhex
;
disaddr:
	call	open
	call	dis16imm
	jr	close
;
dis16imm:
	inxix
	ldx	h,1
	ldx	l,0
	inxix
dis16:
	IF	symbolic
	mvi	a,'.'
	sta	dissym
	shld	symadr
	ENDIF
	mov	a,h
	call	wrh
	mov	a,l
	call	wrh
	ret
;
dis16jp:
	inxix
	lhld	jumpaddr
	jr	dis16
;
;
disbitnum:
	ani	7
	adi	'0'
	jmp	wrc
;
;
	dseg
;
opdis	ds	1
;
	IF	symbolic
dissym	ds	1
symadr	ds	2
	ENDIF
;
	end

