	title	'Z80 Assembler/Disassembler Tables'
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
;
;       Released to the public domain 1987
;
	maclib	z80
	maclib	monopt
;
	cseg
;
	public	analop
	public	mnemtab,reg8nam,r16nam,ccnam
	public	opdesc,jumpmark,jumpaddr,caddress
;
	public	srchmnemo,translate
;
	IF	extended
	extrn	peek,peekbuf
	ENDIF
	extrn	opnd1,opnd2,string
	extrn	cmderr
;
;------------------------------------------------------------------------------
;
;	Table for all mnemonics
;
mnemtab:
	DB	'NOP '		; 0
mnnop	equ	0
	DB	'LD  '		; 1
mnld	equ	1
	DB	'INC '		; 2
mninc	equ	2
	DB	'DEC '		; 3
mndec	equ	3
	DB	'EX  '		; 4
mnex	equ	4
	DB	'DJNZ'		; 5
mndjnz	equ	5
	DB	'JR  '		; 6 
mnjr	equ	6
	DB	'RLCA'		; 7
mnrlca	equ	7
	DB	'RRCA'		; 8
mnrrca	equ	8
	DB	'RLA '		; 9
mnrla	equ	9
	DB	'RRA '		; 10
mnrra	equ	10
	DB	'DAA '		; 11
mndaa	equ	11
	DB	'CPL '		; 12
mncpl	equ	12
	DB	'SCF '		; 13
mnscf	equ	13
	DB	'CCF '		; 14
mnccf	equ	14
	DB	'HALT'		; 15
mnhalt	equ	15
	DB	'ADD '		; 16
mnadd	equ	16
	DB	'ADC '		; 17
mnadc	equ	17
	DB	'SUB '		; 18
mnsub	equ	18
	DB	'SBC '		; 19
mnsbc	equ	19
	DB	'AND '		; 20
mnand	equ	20
	DB	'XOR '		; 21
mnxor	equ	21
	DB	'OR  '		; 22
mnor	equ	22
	DB	'CP  '		; 23
mncp	equ	23
	DB	'RET '		; 24
mnret	equ	24
	DB	'POP '		; 25
mnpop	equ	25
	DB	'JP  '		; 26
mnjp	equ	26
	DB	'CALL'		; 27
mncall	equ	27
	DB	'PUSH'		; 28
mnpush	equ	28
	DB	'RST '		; 29
mnrst	equ	29
	DB	'OUT '		; 30
mnout	equ	30
	DB	'EXX '		; 31
mnexx	equ	31
	DB	'IN  '		; 32
mnin	equ	32
	DB	'DI  '		; 33
mndi	equ	33
	DB	'EI  '		; 34
mnei	equ	34
	DB	'RLC '		; 35
mnrlc	equ	35
	DB	'RRC '		; 36
mnrrc	equ	36
	DB	'RL  '		; 37
mnrl	equ	37
	DB	'RR  '		; 38
mnrr	equ	38
	DB	'SLA '		; 39
mnsla	equ	39
	DB	'SRA '		; 40
mnsra	equ	40
	DB	'NEG '		; 41
mnneg	equ	41
	DB	'SRL '		; 42
mnsrl	equ	42
	DB	'BIT '		; 43
mnbit	equ	43
	DB	'RES '		; 44
mnres	equ	44
	DB	'SET '		; 45
mnset	equ	45
	DB	'RETN'		; 46
mnretn	equ	46
	DB	'IM  '		; 47
mnim	equ	47
	DB	'RETI'		; 48
mnreti	equ	48
	DB	'RRD '		; 49
mnrrd	equ	49
	DB	'RLD '		; 50
mnrld	equ	50
	DB	'LDI '		; 51
mnldi	equ	51
	DB	'CPI '		; 52
mncpi	equ	52
	DB	'INI '		; 53
mnini	equ	53
	DB	'OUTI'		; 54
mnouti	equ	54
	DB	'LDD '		; 55
mnldd	equ	55
	DB	'CPD '		; 56
mncpd	equ	56
	DB	'IND '		; 57
mnind	equ	57
	DB	'OUTD'		; 58
mnoutd	equ	58
	DB	'LDIR'		; 59
mnldir	equ	59
	DB	'CPIR'		; 60
mncpir	equ	60
	DB	'INIR'		; 61
mninir	equ	61
	DB	'OTIR'		; 62
mnotir	equ	62
	DB	'LDDR'		; 63
mnlddr	equ	63
	DB	'CPDR'		; 64
mncpdr	equ	64
	DB	'INDR'		; 65
mnindr	equ	65
	DB	'OTDR'		; 66
mnotdr	equ	66
	DB	'??? '		; 67
mnbadop	equ	67
;
;------------------------------------------------------------------------------
;
;	Tables for register and condition code names
;
reg8nam	DB	'BCDEHLIRAF'
;		 0123456789
;
regb	equ	10h
regc	equ	11h
regd	equ	12h
rege	equ	13h
regh	equ	14h
regl	equ	15h
rega	equ	18h
regi	equ	16h
regr	equ	17h
;
;
r16nam:	DB	'BCDEHLSPAFIXIY'
;		 0 1 2 3 4 5 6
;
regbc	equ	20h
regde	equ	21h
reghl	equ	22h
regsp	equ	23h
regaf	equ	24h
regix	equ	25h
regiy	equ	26h
;
atbc	equ	30h
atde	equ	31h
athl	equ	32h
atsp	equ	33h
atix	equ	34h
atiy	equ	35h
atixi	equ	3dh
atiyi	equ	3eh
;
;
ccnam:	DB	'NZZ NCC POPEP M '
;		 0 1 2 3 4 5 6 7
;
ccdnz	equ	80h
ccdz	equ	81h
ccdnc	equ	82h
ccdc	equ	83h
ccdpo	equ	84h
ccdpe	equ	85h
ccdp	equ	86h
ccdm	equ	87h
;
;
opnim8	equ	40h
opnim16	equ	50h
opnbit	equ	60h
opnjr	equ	70h
opnatc	equ	90h
opnafa	equ	0b0h
opnad16	equ	0a0h
opnad8	equ	0c0h
opnrst	equ	0d0h
;
opnjprg	equ	0e0h		; internal use only, not a real operand
opnjp16	equ	052h		; internal use only, becomes 50h
opncl16	equ	051h		;   "       "   "      "     "
opnjpsp	equ	0f0h
;
;	jump marks
;
jm16	equ	010h		; jump immediate 16-bit (11 means call immed.)
jmsp	equ	020h		; jump stack (ret)
jmreg	equ	030h		; jump register
;
;------------------------------------------------------------------------------
;
;	Table of legal opcodes after DD/FD-prefix
;
preftab:
	DB	09h,19h,21h,22h,23h,29h,2ah,2bh,34h,35h,36h,39h,46h,4eh
	DB	56h,5eh,66h,6eh,70h,71h,72h,73h,74h,75h,77h,7eh,86h,8eh
	DB	096h,09eh,0a6h,0aeh,0b6h,0beh,0cbh,0e1h,0e3h,0e5h,0e9h,0f9h
lpreftab	equ	$-preftab
;
;
;------------------------------------------------------------------------------
;
;	Table for opcodes 00..3F
;
tab00$3f:
	db	mnnop,0,0			; 00
	db	mnld,regbc,opnim16
	db	mnld,atbc,rega
	db	mninc,regbc,0
	db	mninc,regb,0
	db	mndec,regb,0
	db	mnld,regb,opnim8
	db	mnrlca,0,0
;
	db	mnex,regaf,opnafa		; 08
	db	mnadd,reghl,regbc
	db	mnld,rega,atbc
	db	mndec,regbc,0
	db	mninc,regc,0
	db	mndec,regc,0
	db	mnld,regc,opnim8
	db	mnrrca,0,0
;
	db	mndjnz,opnjr,0			; 10
	db	mnld,regde,opnim16
	db	mnld,atde,rega
	db	mninc,regde,0
	db	mninc,regd,0
	db	mndec,regd,0
	db	mnld,regd,opnim8
	db	mnrla,0,0
;
	db	mnjr,opnjr,0			; 18
	db	mnadd,reghl,regde
	db	mnld,rega,atde
	db	mndec,regde,0
	db	mninc,rege,0
	db	mndec,rege,0
	db	mnld,rege,opnim8
	db	mnrra,0,0
;
	db	mnjr,ccdnz,opnjr		; 20
	db	mnld,reghl,opnim16
	db	mnld,opnad16,reghl
	db	mninc,reghl,0
	db	mninc,regh,0
	db	mndec,regh,0
	db	mnld,regh,opnim8
	db	mndaa,0,0
;
	db	mnjr,ccdz,opnjr			; 28
	db	mnadd,reghl,reghl
	db	mnld,reghl,opnad16
	db	mndec,reghl,0
	db	mninc,regl,0
	db	mndec,regl,0
	db	mnld,regl,opnim8
	db	mncpl,0,0
;
	db	mnjr,ccdnc,opnjr		; 30
	db	mnld,regsp,opnim16
	db	mnld,opnad16,rega
	db	mninc,regsp,0
	db	mninc,athl,0
	db	mndec,athl,0
	db	mnld,athl,opnim8
	db	mnscf,0,0
;
	db	mnjr,ccdc,opnjr			; 38
	db	mnadd,reghl,regsp
	db	mnld,rega,opnad16
	db	mndec,regsp,0
	db	mninc,rega,0
	db	mndec,rega,0
	db	mnld,rega,opnim8
	db	mnccf,0,0
;
ltab00$3f	equ	($-tab00$3f)/3
;
;------------------------------------------------------------------------------
;
;	Table for Opcodes 40..BF (Groups of 8)
;
tab40$bf:
	db	mnld,regb,1fh
	db	mnld,regc,1fh
	db	mnld,regd,1fh
	db	mnld,rege,1fh
	db	mnld,regh,1fh
	db	mnld,regl,1fh
	db	mnld,athl,1fh
	db	mnld,rega,1fh
	db	mnadd,rega,1fh
	db	mnadc,rega,1fh
	db	mnsub,1fh,0
	db	mnsbc,rega,1fh
	db	mnand,1fh,0
	db	mnxor,1fh,0
	db	mnor,1fh,0
	db	mncp,1fh,0
;
ltab40$bf	equ	($-tab40$bf)/3
;
;------------------------------------------------------------------------------
;
;	Table for Opcodes C0..FF
;
tabc0$ff:
	db	mnret,ccdnz,opnjpsp	; c0
	db	mnpop,regbc,0
	db	mnjp,ccdnz,opnjp16
	db	mnjp,opnjp16,0
	db	mncall,ccdnz,opncl16
	db	mnpush,regbc,0
	db	mnadd,rega,opnim8
	db	mnrst,opnrst+0,0
;
	db	mnret,ccdz,opnjpsp	; c8
	db	mnret,opnjpsp,0
	db	mnjp,ccdz,opnjp16
	db	mnbadop,0,0
	db	mncall,ccdz,opncl16
	db	mncall,opncl16,0
	db	mnadc,rega,opnim8
	db	mnrst,opnrst+1,0
;
	db	mnret,ccdnc,opnjpsp	; d0
	db	mnpop,regde,0
	db	mnjp,ccdnc,opnjp16
	db	mnout,opnad8,rega
	db	mncall,ccdnc,opncl16
	db	mnpush,regde,0
	db	mnsub,opnim8,0
	db	mnrst,opnrst+2,0
;
	db	mnret,ccdc,opnjpsp	; d8
	db	mnexx,0,0
	db	mnjp,ccdc,opnjp16
	db	mnin,rega,opnad8
	db	mncall,ccdc,opncl16
	db	mnbadop,0,0
	db	mnsbc,rega,opnim8
	db	mnrst,opnrst+3,0
;
	db	mnret,ccdpo,opnjpsp	; e0
	db	mnpop,reghl,0
	db	mnjp,ccdpo,opnjp16
	db	mnex,atsp,reghl
	db	mncall,ccdpo,opncl16
	db	mnpush,reghl,0
	db	mnand,opnim8,0
	db	mnrst,opnrst+4,0
;
	db	mnret,ccdpe,opnjpsp	; e8
	db	mnjp,athl,opnjprg
	db	mnjp,ccdpe,opnjp16
	db	mnex,regde,reghl
	db	mncall,ccdpe,opncl16
	db	mnbadop,0,0
	db	mnxor,opnim8,0
	db	mnrst,opnrst+5,0
;
	db	mnret,ccdp,opnjpsp	; f0
	db	mnpop,regaf,0
	db	mnjp,ccdp,opnjp16
	db	mndi,0,0
	db	mncall,ccdp,opncl16
	db	mnpush,regaf,0
	db	mnor,opnim8,0
	db	mnrst,opnrst+6,0
;
	db	mnret,ccdm,opnjpsp	; f8
	db	mnld,regsp,reghl
	db	mnjp,ccdm,opnjp16
	db	mnei,0,0
	db	mncall,ccdm,opncl16
	db	mnbadop,0,0
	db	mncp,opnim8,0
	db	mnrst,opnrst+7,0
;
ltabc0$ff	equ	($-tabc0$ff)/3
;
;------------------------------------------------------------------------------
;
;	Table for prefix-codes ED
;
tabedpref:
	db	40h,mnin,regb,opnatc
	db	41h,mnout,opnatc,regb
	db	42h,mnsbc,reghl,regbc
	db	43h,mnld,opnad16,regbc
	db	44h,mnneg,0,0
	db	45h,mnretn,opnjpsp,0
	db	46h,mnim,opnbit+0,0
	db	47h,mnld,regi,rega
;
	db	48h,mnin,regc,opnatc
	db	49h,mnout,opnatc,regc
	db	4ah,mnadc,reghl,regbc
	db	4bh,mnld,regbc,opnad16
	db	4dh,mnreti,opnjpsp,0
	db	4fh,mnld,regr,rega
;
	db	50h,mnin,regd,opnatc
	db	51h,mnout,opnatc,regd
	db	52h,mnsbc,reghl,regde
	db	53h,mnld,opnad16,regde
	db	56h,mnim,opnbit+1,0
	db	57h,mnld,rega,regi
;
	db	58h,mnin,rege,opnatc
	db	59h,mnout,opnatc,rege
	db	5ah,mnadc,reghl,regde
	db	5bh,mnld,regde,opnad16
	db	5eh,mnim,opnbit+2,0
	db	5fh,mnld,rega,regr
;
	db	60h,mnin,regh,opnatc
	db	61h,mnout,opnatc,regh
	db	62h,mnsbc,reghl,reghl
	db	67h,mnrrd,0,0
;
	db	68h,mnin,regl,opnatc
	db	69h,mnout,opnatc,regl
	db	6ah,mnadc,reghl,reghl
	db	6fh,mnrld,0,0
;
	db	72h,mnsbc,reghl,regsp
	db	73h,mnld,opnad16,regsp
;
	db	78h,mnin,rega,opnatc
	db	79h,mnout,opnatc,rega
	db	7ah,mnadc,reghl,regsp
	db	7bh,mnld,regsp,opnad16
;
	db	0a0h,mnldi,0,0
	db	0a1h,mncpi,0,0
	db	0a2h,mnini,0,0
	db	0a3h,mnouti,0,0
	db	0a8h,mnldd,0,0
	db	0a9h,mncpd,0,0
	db	0aah,mnind,0,0
	db	0abh,mnoutd,0,0
;
	db	0b0h,mnldir,0,0
	db	0b1h,mncpir,0,0
	db	0b2h,mninir,0,0
	db	0b3h,mnotir,0,0
	db	0b8h,mnlddr,0,0
	db	0b9h,mncpdr,0,0
	db	0bah,mnindr,0,0
	db	0bbh,mnotdr,0,0
;
ltabedpref	equ	($-tabedpref)/4
;
;
;	table entry for HALT opcode
;
tab76:
	db	mnhalt,0,0
;
;------------------------------------------------------------------------------
;
;	Table for CB-Prefix Opcodes (Groups of 8)
;
tabcb00$ff:
	db	mnrlc,1fh,0		; 00
	db	mnrrc,1fh,0		; 08
	db	mnrl,1fh,0		; 10
	db	mnrr,1fh,0
	db	mnsla,1fh,0
	db	mnsra,1fh,0
	db	mnbadop,0,0
	db	mnsrl,1fh,0
;
	db	mnbit,60h,1fh
	db	mnbit,61h,1fh
	db	mnbit,62h,1fh
	db	mnbit,63h,1fh
	db	mnbit,64h,1fh
	db	mnbit,65h,1fh
	db	mnbit,66h,1fh
	db	mnbit,67h,1fh
;
	db	mnres,60h,1fh
	db	mnres,61h,1fh
	db	mnres,62h,1fh
	db	mnres,63h,1fh
	db	mnres,64h,1fh
	db	mnres,65h,1fh
	db	mnres,66h,1fh
	db	mnres,67h,1fh
;
	db	mnset,60h,1fh
	db	mnset,61h,1fh
	db	mnset,62h,1fh
	db	mnset,63h,1fh
	db	mnset,64h,1fh
	db	mnset,65h,1fh
	db	mnset,66h,1fh
	db	mnset,67h,1fh
;
ltabcb00$ff	equ	($-tabcb00$ff)/3
;
;
;
;	Operand description:
;
;		00	no operand
;		1x	8-bit register name
;			(x = pointer to 'reg8nam')
;		2x	16-bit register name
;			(x = pointer to 'reg16nam')
;		3x	memory register, x=pointer to 'reg16nam'
;			bit 3 = 1: signed offset follows
;		40	immediate 8-bit follows
;		50	immediate 16-bit follows
;		6x	x = bit number/ int-mode-number
;		70	jump offset follows (16-bit immediate value)
;		8x	condition code
;			(x = pointer to 'ccnam')
;		90	(C)
;		A0	address follows
;		B0	AF'
;		C0	8-bit (port-)address follows
;		Dx	restart (8-bit immediate value follows)
;
;	analop:		analyse opcode
;
;		entry:	A/HL = first opcode byte address
;
;		exit:	B = opcode length
;			C = menmonic table pointer
;			HL = next opcode address
;			opdesc contains operand description
;
;		uses:	all regs
;
analop:
	shld	caddress
	IF	extended
	call	peek
	push	h
	lxix	peekbuf
	ELSE
	push	h
	push	h
	popix
	ENDIF
	lxiy	opdesc
	mvi	b,1		; default length
	xra	a
	sta	prefix		; clear prefix
	sta	condit
	sta	jumpmark
	call	analop1		; analyse
	mviy	0,0		; terminate opdesc
	pop	h
	mov	e,b
	mvi	d,0
	dad	d
	ret
;
;
analop1:
	ldx	a,0		; load opcode
	mvi	c,3		; offset of IX to HL in "r16nam"
	cpi	0ddh
	jrz	prefx		; IX-prefix
	cpi	0fdh		; IY-prefix
	jrnz	anal10		; jump if no prefix
	inr	c
prefx:
	mov	a,c
	sta	prefix
	ldx	a,2		; get offset
	sta	offset		; store it
	lxi	h,preftab
	ldx	a,1		; check next byte
	lxi	b,lpreftab
	ccir			; allowed combination ?
	jnz	operr		; error if not
	cpi	0cbh		; shift/bit op ?
	jrnz	prefx10		; ok if not
	ldx	a,3		; get opcode (byte 2 is offset)
	cpi	36h		; 36 is not allowed
	jz	operr
	ani	7
	cpi	6		; only .6/.E allowed
	jnz	operr		; error if not
prefx10:
	mvi	b,2		; 2 bytes opcode
	inxix			; get next byte
	ldx	a,0		; opcode
;
;	next byte can't be dd/fd prefix, so fall through
;
anal10:
	cpi	0cbh
	jrz	exshiftop	; extended shift / bit operation
	cpi	0edh
	jrz	specop		; special operation
	lxi	h,tab00$3f
	cpi	040h
	jrc	anal20		; direct table access for 00..3f
	cpi	0c0h
	jrc	anal30		; branch for 40..bf
	lxi	h,tabc0$ff	; direct table for c0..ff
	sui	0c0h		; offset
;
anal20:
	mov	e,a
	add	a
	add	e		; opcode * 3
	mov	e,a
	mvi	d,0
	dad	d		; table location
anal25:
	mov	c,m		; mnemonic
	inx	h
	mov	a,m		; first operand
	ora	a
	rz			; ready if no operand
	call	analopnd	; analyse operand
	inx	h
	mov	a,m		; second operand
	ora	a
	rz			; ready if no second operand
	jmp	analopnd	; analyse second operand
;
;
anal30:				; here for opcodes 40..BF
	cpi	76h
	mvi	c,mnhalt	; HALT is a special case
	rz
	sui	40h
	rrc
	rrc			; divide opcode by 8
	rrc
	ani	0fh
	lxi	h,tab40$bf
	jr	anal20		; normal procedure now
;
;
;	Opcode prefix CB:	Extended shifts, bit operations
;
exshiftop:
	inxix			; opcode is next byte
	inr	b
	lda	prefix		; prefix ?
	ora	a
	jrz	exshif1		; ok if not
	inxix			; skip offset if prefix
exshif1:
	ldx	a,0		; load opcode
	rrc
	rrc			; divide by 8
	rrc
	ani	1fh
	lxi	h,tabcb00$ff
	jr	anal20		; normal procedure from here
;
;
;	Opcode prefix ED:	Special operations
;
specop:
	inxix			; opcode is next byte
	inr	b
	ldx	a,0
	mvi	c,ltabedpref
	lxi	h,tabedpref
specoplp:
	cmp	m
	inx	h
	jrz	anal25		; continue normally if found
	inx	h
	inx	h
	inx	h
	dcr	c
	jrnz	specoplp
;
;	fall through to operr for undefined ED-opcode
;
operr:
	mvi	c,mnbadop
	mvi	b,1		; length of bad opcode is 1
	ret
;
;------------------------------------------------------------------------------
;
;	analopnd:	analyse operand
;
;		entry:	A = operand code
;
analopnd:
	sty	a,0		; store
	inxiy
	push	psw
	rrc
	rrc
	rrc
	rrc
	ani	0fh
	dcr	a
	add	a
	mov	e,a
	mvi	d,0
	pop	psw
	push	h
	lxi	h,analopntab
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	xchg
	xthl
aopret:
	ret			; enter table
;
analopntab:
	dw	aopr8		; 10
	dw	aopr16		; 20
	dw	aopa16		; 30
	dw	aopim8		; 40
	dw	aopim16		; 50
	dw	aopret		; 60
	dw	aopjr		; 70
	dw	aopccd		; 80
	dw	aopret		; 90
	dw	aopim16		; a0
	dw	aopret		; b0
	dw	aopim8		; c0
	dw	aoprst		; d0
	dw	aopjprg		; e0
	dw	aopjpsp		; f0
;
;
aopccd:
	mvi	a,80h
	sta	condit
	ret
;
aopr8:
	ani	0fh
	cpi	0fh
	rnz			; ready if not undetermined
	ldx	a,0		; get opcode again
	ani	7		; get register
	cpi	7		; A ?
	jrnz	aopr81
	inr	a		; internally, A is 8
aopr81:
	ori	10h
	sty	a,-1		; replace
	cpi	16h		; (HL)
	rnz			; ready if not (HL)
	mviy	32h,-1		; replace by (HL)
;
memopnd:
	lda	prefix
	ora	a
	rz			; ok if no prefix
	addy	-1		; else add prefix offset to (HL)
	sty	a,-1
;
	ldx	a,0		; get opcode again
	cpi	0e9h		; JP (rr) ?
	rz			; no offset for JP (rr)
;
	sety	3,-1		; else mark offset follows
	lda	offset		; copy offset
	sty	a,0
	inxiy			; point to next
	inr	b		; offset takes one byte
	ret
;
aopjr:
	ldx	a,0		; opcode again
	cpi	10h		; DJNZ ?
	jrnz	aopjr1
	mvi	a,80h
	sta	condit		; DJNZ is conditional
aopjr1:
	ldx	a,1
	sty	a,0
	inxiy			; point to next
	inr	b		; offset takes one byte
	push	h
	lhld	caddress	; current addr
	inx	h
	inx	h		; +2
	mov	e,a
	mvi	d,0		; calculate absolute jump address
	rlc
	jrnc	aopjr10
	mvi	d,0ffh		; extend sign
aopjr10:
	dad	d
	xchg
	pop	h
	xra	a
	jr	mkjm16		; mark as 16-bit jump
;
aopa16:
	ani	7
	cpi	2
	rnz			; ready if not HL
	jr	memopnd
;
aopr16:
	ani	7
	cpi	2
	rnz			; ready if not HL
	lda	prefix
	addy	-1
	sty	a,-1
	ret
;
;
aopim16:
	ldx	e,1		; copy value
	sty	e,0
	ldx	d,2
	sty	d,1
	inxiy
	inxiy
	inr	b
	inr	b		; 2 bytes for opcode
	ani	7		; jump ?
	rz			; ready if not
	push	psw
	ldy	a,-3
	ani	0f0h		; clear lower nibble in operand-description
	sty	a,-3
	pop	psw
mkjm16:
	sded	jumpaddr
	ori	jm16
mkjmp:
	push	h
	lxi	h,condit
	ora	m
	sta	jumpmark
	pop	h
	ret
;
;
aopim8:
	ldx	d,1
	lda	prefix		; prefix ?
	ora	a
	jrz	aopim81		; ok if not
	ldx	d,2		; value is in next byte if prefix
aopim81:
	sty	d,0		; copy value
	inxiy
	inr	b		; one byte for opcode
	ret
;
;
aoprst:
	ani	7
	mov	d,a
	inr	d
	mvi	a,-8
aoprstlp:
	adi	8
	dcr	d
	jrnz	aoprstlp
	sty	a,0
	inxiy
	mov	e,a
	mvi	a,1		; call marker
	jr	mkjm16		; go mark jump
;
;
aopjprg:
	ldy	a,-2		; previous operand
	jr	aopjj
;
aopjpsp:
	mvi	a,jmsp
;
aopjj:
	mviy	0,-1		; clear field, not an operand
	jr	mkjmp
;
;
;------------------------------------------------------------------------------
;
;	Routines for Assembly
;
;------------------------------------------------------------------------------
;
;	srchmnemo:	search mnemonic
;
;		entry:	HL = pointer to mnemonic
;
;		exit:	Carry set if not found
;			A = mnemonic index
;
srchmnemo:
	lxi	d,mnemtab
	mvi	b,mnbadop	; number of entries
	mvi	c,0		; index
srcmnloop:
	push	b
	push	h		; save start
	mvi	b,4
	mvi	c,0
srcmncmp:
	ldax	d
	sub	m
	ora	c
	mov	c,a		; all bytes must match
	inx	h
	inx	d
	djnz	srcmncmp
	pop	h
	pop	b
	ora	a
	mov	a,c
	rz			; ready if found
	inr	c
	djnz	srcmnloop
	stc
	ret			; exit with carry set
;
;
;------------------------------------------------------------------------------
;
;
;	translate:	translate op description into opcode
;
;		entry:	A = mnemonic index
;			IX = opnd1
;			IY = opnd2
;
translate:
	mov	c,a		; mnemo into C
	xra	a
	sta	prefix
	sta	prefix2
	dcr	a
	sta	regpref		; registers have preference this time
	call	trymatch	; try to match mnemo and operands
	jrnc	transl10
	xra	a
	sta	regpref		; no register preference this time
	call	trymatch
	rc			; return if no match
;
;	we have a match, now assemble the opcode
;
;
transl10:
	mov	a,e
	cpi	4		; ED-prefix-table ?
	jrnz	matchnoed
	dcx	h		; then opcode is one before mnemo
	mov	a,m
	inx	h
	sta	opcode		; correct opcode
;
matchnoed:
	mvi	b,1		; B = length of opcode
	lxix	string
	lda	prefix		; is there an IX/IY prefix ?
	ora	a
	jrz	match10
	stx	a,0		; yes, store & increase length
	inxix
	inr	b
;
match10:
	lda	prefix2
	ora	a		; opcode prefix ?
	jrz	match20
	stx	a,0
	inxix
	inr	b
;
match20:
	lda	opcode		; get opcode
	stx	a,0		; store it
	dcr	d		; opcode offset
	jrz	match25		; ok if 1
	inx	h
	mov	a,m
	dcx	h
	cpi	1fh		; operand 1 undetermined ?
	lda	opnd1+1
	jrz	match22
	lda	opnd2+1		; else insert reg-num of second opnd into op
match22:
	call	make8bit
	ani	0fh
	orx	0
	stx	a,0
;
match25:
	lda	prefix		; check again for IX/IY prefix
	ora	a
	jrz	match40		; ok if no prefix
	push	h
	lxi	h,preftab
	lda	string+1	; opcode
	push	b		; check opcode against table of allowed codes
	lxi	b,lpreftab
	ccir
	pop	b
	pop	h
	stc
	rnz			; error if prefix with illegal opcode
;
	mov	a,m		; check mnemo
	cpi	mnjp		; is it JP (IX/IY) ?
	jrz	match40		; then no offset
	inx	h		; first opnd
	lxiy	opnd1
	mov	a,m
	inx	h		; second opnd
	cpi	athl
	jrz	match30
	cpi	1fh
	jrz	match30
	mov	a,m
	cpi	athl
	jrz	match29
	cpi	1fh
	jrnz	match39		; no offset if not (..)
match29:
	lxiy	opnd2
match30:
	ldy	a,2		; offset marker
	ora	a
	jrz	match35		; use 0 if no offset given
	ldy	a,3		; else use specified offset
match35:
	mov	d,a		; save
	lda	prefix2
	ora	a		; another prefix ?
	jrz	match36		; ok if not
	ldx	a,0		; else copy opcode
	stx	d,0
	mov	d,a
match36:
	stx	d,1
	inxix
	inr	b
;
match39:
	dcx	h
	dcx	h
;
match40:
	inx	h		; first operand
	mov	a,m
	ora	a
	rz			; ready if no operands
	lxiy	opnd1
	call	insopnd
	inx	h
	mov	a,m
	ora	a
	rz			; ready if no second operand
	lxiy	opnd2
	call	insopnd
	ora	a		; clear carry
	ret
;
;	insert operand
;
insopnd:
	cpi	40h
	rc			; no change if register
	jrz	insopni8
	cpi	60h
	jrc	insopni16	; jump if 16-bit immediate
	cpi	70h
	rc			; ready if IM/BIT
	jrz	insopnjr	; jump if jump offset
	cpi	0a0h
	rc			; ready if condition code or (C)
	jrz	insopni16
	cpi	0c0h
	rc			; ready if AF'
	rnz			; ready if not 8-bit port address
;
insopni8:
	ldy	a,5		; lower byte of value
insopnst:
	stx	a,1		; store in opcode
	inxix
	inr	b
	ret
;
insopni16:
	call	insopni8
	ldy	a,6
	jr	insopnst
;
insopnjr:
	lhld	caddress	; current address
	inx	h
	inx	h		; + 2
	ldy	e,5
	ldy	d,6		; jump address specified
	xchg
	ora	a
	dsbc	d		; calculate offset
	jrc	insopnjr1	; branch if negative offset
	mov	a,h
	ora	a
	jnz	cmderr		; abort if offset > 255
	mov	a,l
	ani	80h
	jnz	cmderr		; abort if offset > 127
	mov	a,l
	jr	insopnst	; go store offset
;
insopnjr1:
	inr	h
	jnz	cmderr		; abort if offset < -256
	mov	a,l
	ani	80h
	jz	cmderr		; abort if offset < -128
	mov	a,l
	jr	insopnst	; go store offset
;
;
;	make8bit:	change operand to conform to 8-bit register
;
make8bit:
	ora	a
	stc
	rz			; ret if opnd empty
	cpi	20h
	jrnc	make810		; branch if 16-bit
	cpi	16h
	cmc
	rnc			; ready if B..L
	cpi	18h		; A ?
	stc
	rnz			; error if I or R
	dcr	a
	ora	a
	ret			; A is 17h for opcode
;
make810:
	cpi	32h		; must be (HL)
	stc
	rnz			; error if not
	mvi	a,16h		; (HL) is 16h for opcode
	ora	a
	ret
;
;------------------------------------------------------------------------------
;
;	trymatch:	try to match mnemo and operands
;
;		entry:	C = mnemo
;			IX = operand 1 description
;			IY = operand 2 description
;
trymatch:
	mvi	e,3		; E = length of a table element
	mvi	d,1		; D = offset of opcodes within table
	xra	a
	sta	opcode		; init opcode
	sta	prefix2		; init opcode prefix
	lxi	h,tab00$3f
	mvi	b,ltab00$3f
	call	srchtab
	rnc
	mvi	d,8
	mvi	b,ltab40$bf
	call	srchtab
	rnc
	mvi	d,1
	mvi	b,ltabc0$ff
	call	srchtab
	rnc
	xra	a
	sta	opcode		; reset opcode
	mvi	a,0cbh
	sta	prefix2
	mvi	d,8
	lxi	h,tabcb00$ff
	mvi	b,ltabcb00$ff
	call	srchtab
	rnc
;
	mvi	a,0edh
	sta	prefix2
	mvi	d,1
	mvi	e,4
	lxi	h,tabedpref+1
	mvi	b,ltabedpref
	call	srchtab
	rnc
;
	xra	a
	sta	prefix2
	mvi	a,076h			; HALT opcode
	sta	opcode
	mvi	e,3
	mvi	b,1
	lxi	h,tab76
;
;	return via srchtab
;
srchtab:
	mov	a,m
	cmp	c		; compare mnemo
	jrnz	srcht10
	call	opmatch		; try to match operands if same
	rnc			; ready if match
srcht10:
	mov	a,d		; else continue: save opcode offset
	mvi	d,0
	dad	d		; next table element
	mov	d,a
	push	h
	lxi	h,opcode
	add	m		; increase opcode
	mov	m,a
	pop	h
	djnz	srchtab		; next
	stc			; no match
	ret			; return with carry set
;
;
;	opmatch:	try to match operands
;
;		entry:	HL = opcode descriptor
;			IX, IY = operands
;
opmatch:
	xra	a
	sta	prefix
	push	b
	push	d
	push	h			; save everything
	pushix
	inx	h			; first operand
	mov	b,m
	call	tryopnd
	jrc	opmatchret		; return with error if no match
	inx	h
	mov	b,m			; second operand
	pushiy
	popix
	call	tryopnd
opmatchret:
	popix
	pop	h
	pop	d
	pop	b
	ret
;
;
;	tryopnd:	try to match operand
;
;		entry:	B = operand descriptor byte
;			IX = operand
;
tryopnd:
	mov	a,b
	ora	a
	jrnz	tryopnd10
tryopndnull:
	orx	1
	orx	4
	orx	7
	rz			; match if no operand
	stc
	ret			; else no match
;
tryopnd10:
	cpi	40h
	jrnc	tryopnd20	; branch if not register
	cmpx	1		; compare
	jrz	tryopndisreg	; ok if match
	cpi	1fh
	stc
	rnz			; no match if not undetermined 8-bit reg
	ldx	a,1
	call	make8bit
	rc			; error if no 8-bit reg
tryopndisreg:
	ldx	a,0
	ora	a
	rz			; match if no prefix
	sta	prefix		; store prefix
	ret			; ready
;
tryopnd20:
	jrz	tryopndimm	; branch if immediate 8-bit (40)
	ani	0f0h
	cpi	60h
	jrc	tryopndimm	; branch if immediate 16-bit (5x)
	jrz	tryopndbitim	; branch if bit/int-mode (6x)
	cpi	80h
	jrc	tryopndimm	; immediate (70)
	jrz	tryopndcc	; cond-code (8x)
	cpi	0a0h		; address ?
	jrc	tryopndcmp	; (C) (90)
	jrz	tryopndaddr	; address (A0)
	cpi	0c0h		; 8-bit address ?
	jrc	tryopndcmp	; AF (B0)
	jrz	tryopndaddr	; 8-bit-address	(C0)
	cpi	0d0h
	mvi	a,0
	jrnz	tryopndnull	; > D0 is no real operand
;
;	Dx: restart
;
	ldx	a,4
	cpi	50h		; must be immediate value
	stc
	rnz
	ldx	a,6
	ora	a
	stc
	rnz			; error if > 255
	ldx	a,5
	mvi	c,0
tryopndrst:
	sui	8
	jrc	tryopndrst1
	inr	c
	jr	tryopndrst
tryopndrst1:
	adi	8
	stc
	rnz			; error if not divisible by 8
	mov	a,c
	ori	0d0h
	cmp	b
	rz
	stc
	ret
;
tryopndcc:
	ldx	a,7
tryopndcc1:
	cmp	b
	rz
	stc
	ret
;
tryopndcmp:
	ldx	a,1
	jr	tryopndcc1
;
tryopndimm:
	ldx	a,4
	cpi	50h
	jrz	tryopndimrp
	stc
	ret
;
tryopndaddr:
	ldx	a,4
	cpi	0a0h
	jrz	tryopndimrp
	stc
	ret
;
tryopndimrp:
	lda	regpref		; register preference ?
	ora	a
	rz			; match ok if not
	ldx	a,1		; is it a register ?
	ora	a
	rz			; ret with match if not a register
	stc
	ret			; ret with no match if register operand
;
tryopndbitim:
	ldx	a,4
	cpi	50h
	stc
	rnz			; must be value
	ldx	a,6
	ora	a
	stc
	rnz			; must be < 255
	ldx	a,5
	cpi	8
	cmc
	rc			; must be <= 7
	ori	60h
	jr	tryopndcc1
;
;------------------------------------------------------------------------------
;
	dseg
;
prefix	ds	1
offset	ds	1
condit	ds	1
caddress	ds	2
;
jumpaddr	ds	2
jumpmark	ds	1
;
opdesc	ds	8
;
prefix2		equ	offset
opcode		equ	condit
regpref		equ	opdesc
;
	end

