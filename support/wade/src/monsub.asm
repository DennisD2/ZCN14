	title	'Subroutines for Monitor'
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
	public	wrhex,wrhexdig,wrword,wrbit,wrdec,wrstr,wraddr
	public	crlf,kbint,tkbint,space,space2
	public	isdigit,isletter,isspecial,iscontrol
	public	mul16,div16
;
	public	rdregister,bytestring
	public	rdregval,rdword,rdstrword
	public	readstring,skipsep,skipsp,getch,testch,sgetch,stestch
;
	public	string
;
	IF	symbolic
	extrn	rdsymbol
	ENDIF
	extrn	expression
	extrn	monmain,cmderr
	extrn	rdchar,pollch,wrchar
	extrn	regi,regiff,regbc,altbc,regpc
	extrn	reg8nam,r16nam,iffstr
	extrn	variables
	IF	hilo
	extrn	highval,lowval,maxval,topval
	ENDIF
	extrn	listaddr
;
	IF	extended
	extrn	peek,peekbuf,cbank,bankok,xltbank
	ENDIF
;
;
;
;	mul16:	multiply HL by DE giving HL
;
mul16:
	push	psw
	push	b
	mov	c,l
	mov	b,h
	lxi	h,0
	mvi	a,15
mlp:
	slar	e
	ralr	d
	jrnc	mlp1
	dad	b
mlp1:
	dad	h
	dcr	a
	jrnz	mlp
	ora	d
	jp	mlex
	dad	b
mlex:
	pop	b
	pop	psw
	ret
;
;
;	div16:	unsigned divide HL by DE giving HL, remainder in DE
;
div16:
	push	psw
	push	b
	mov	a,e
	ora	d
	jz	cmderr
	mov	c,l
	mov	a,h
	lxi	h,0
	mvi	b,16
;
dvloop:
	ralr	c
	ral
	ralr	l
	ralr	h
	push	h
	dsbc	d
	cmc
	jrc	drop
	xthl
drop:
	xthl
	pop	h
	djnz	dvloop
	xchg
	ralr	c
	mov	l,c
	ral
	mov	h,a
	pop	b
	pop	psw
	ret
;
;------------------------------------------------------------------------------
;
;	wrdec:	write HL as unsigned decimal
;
;		entry: A = sign character
;
wrdec:
	push	b
	push	d
	push	h
;
	mov	c,a
	mvi	b,5		; 5 digits
	xra	a
	push	psw		; mark end
wrdloop:
	lxi	d,10
	call	div16		; divide by 10
	mov	a,e		; remainder
	adi	'0'
	push	psw		; save digit
	dcr	b
	mov	a,h
	ora	l
	jrnz	wrdloop		; loop if more digits remain
;
	mov	a,b
	ora	a
	jrz	wrdsw
wrdsf:
	call	space
	djnz	wrdsf		; space fill
wrdsw:
	mov	a,c
	call	wrchar		; write sign
;
wrdwrit:
	pop	psw		; get digit
	jrz	wrdex		; ready if end marker
	call	wrchar
	jr	wrdwrit
;
wrdex:
	pop	h
	pop	d
	pop	b
	mvi	a,'.'
	jmp	wrchar		; mark as decimal
;
;
;	wrbit:	write A as bitstream
;
wrbit:
	push	b
	mvi	b,8
wrbitloop:
	rlc
	push	psw
	ani	1
	adi	'0'
	call	wrchar
	mov	a,b
	cpi	5
	jrnz	wrbit1
	mvi	a,'_'		; write separator
	call	wrchar
wrbit1:
	pop	psw
	djnz	wrbitloop
	pop	b
	mvi	a,'"'
	jmp	wrchar		; mark as bitstream
;
;
;	wrstr:		write zero-terminated string
;
;		entry:	HL = string address
;
wrstr:
	mov	a,m
	ora	a
	rz
	inx	h
	call	wrchar
	jr	wrstr
;
;
;	crlf:		write cr/lf, check for interrupt from terminal
;
crlf:
	mvi	a,0dh
	call	wrchar
	mvi	a,0ah
	call	wrchar
kbint:
	call	tkbint
	rz
	jmp	monmain
;
tkbint:
	call	pollch
	rz
kbdint:
	call	rdchar
	cpi	'S'-40h
	jrz	kbdint
	cpi	'Q'-40h
	rz
	cpi	' '
kbdint10:
	rnz			; abort if other than XON/XOFF or space
	call	rdchar
	cpi	' '
	rz
	cpi	'Q'-40h
	rz
	cpi	'S'-40h
	jr	kbdint10
;
;
;	space2:		write 2 spaces
;
space2:
	call	space
;
;	space:		write 1 space
;
space:
	mvi	a,' '
	jmp	wrchar
;
;
;	wraddr:		write A/HL as 24-bit address
;
wraddr:
	IF	extended
	cpi	0ffh		; default ?
	jrz	wrword		; then dont write bank
	push	h
	lxi	h,cbank
	cmp	m		; same as current bank ?
	pop	h
	jrz	wrword		; then dont write
	call	wrhex		; write bank
	mvi	a,':'
	call	wrchar
	ENDIF
;
;	return via wrword
;
;
;	wrword:		write HL as hex word
;
wrword:
	mov	a,h
	call	wrhex
	mov	a,l
;
;
;	wrhex:		write A as hex number
;
wrhex:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	wrhexdig
	pop	psw
;
;
;	wrhexdig:	write lower nibble of A as hex digit
;
wrhexdig:
	ani	0fh
	adi	'0'
	cpi	'9'+1
	jc	wrchar
	adi	'A'-'0'-10
	jmp	wrchar
;
;
;------------------------------------------------------------------------------
;
;	rdword:		read hex/dec/bit-word from input buffer
;
;		entry:	IX = current position
;
;		exit:	IX = first non-digit character
;			HL = word
;			Carry-flag set if nothing found
;
rdword:
	call	skipsp
	pushix			; save start pos
	mvi	b,0		; B = digit counter
;
;	first count the number of digits and determine base
;
rdcdigs:
	call	getch		; get char
	jrz	rdwhex		; try hex if end of string
	cpi	'.'		; '.' means decimal
	jrz	rdwdec
	cpi	'"'		; '"' means bit
	jrz	rdwbit
	call	isdigit
	jrnc	rdcwnxt		; digit, get next char
	cpi	'A'
	jc	rdwhex		; no digit, try hex
	cpi	'F'+1
	jnc	rdwhex		; no digit, try hex
rdcwnxt:
	inr	b		; increase no. of digits found
	jr	rdcdigs
;
;	decimal number
;
rdwdec:
	popix			; go back to start
	mov	a,b
	ora	a
	jz	cmderr		; error if no digits
	lxi	h,0
rdwdlp:
	call	getch
	sui	'0'
	cpi	10
	jnc	cmderr		; error if no decimal digit
	lxi	d,10
	call	mul16		; multiply previous result by 10
	mov	e,a
	mvi	d,0
	dad	d		; add digit
	djnz	rdwdlp
	inxix			; skip dec-marker
;
rdwready:
	ora	a		; clear carry
	ret
;
;	bit string
;
rdwbit:
	popix			; back to start
	mov	a,b
	ora	a
	jz	cmderr		; error if no digits
	lxi	h,0
rdwblp:
	call	getch
	sui	'0'
	cpi	2
	jnc	cmderr		; error if not 0/1
	rar			; into carry
	ralr	l		; shift bit into lsb of HL
	ralr	h		; make it a 16-bit shift
	djnz	rdwblp
	inxix			; skip '"'
	jr	rdwready
;
;	hex number or no number at all
;
rdwhex:
	popix			; back to start
	lxi	h,0
	shld	temp		; clear temporary result
	lxi	h,temp		; set up for rld
	mov	a,b
	ora	a
	jrnz	rdwhexlp	; ok if digits
	stc			; mark no valid number
	ret
;
rdwhexlp:
	call	getch
	sui	'0'
	cpi	10
	jrc	rdwhexb		; ok if 0..9
	sui	'A'-'0'-10	; else A..F
rdwhexb:
	rld			; shift temp left by 4
	inx	h
	rld
	dcx	h
	djnz	rdwhexlp
	lhld	temp		; load result
	jr	rdwready
;
;
;	rdstrword:	read string word
;
;		entry:	IX = input pointer
;
;		exit:	HL = 2 last chars
;			Carry set if no quoted string
;
rdstrword:
	call	skipsp
	ldx	a,0
	cpi	''''
	stc
	rnz			; ret if no string
	lxi	h,0
	inxix
rdstrwlp:
	mov	h,l		; shift result left by 8
	call	getstrch	; get character
	mov	l,a		; into result
	ldx	a,0		; next char
	cpi	''''
	jrnz	rdstrwlp	; ok if not terminator
	cmpx	1		; next char a '''' too ?
	jrz	rdstrwlp	; then loop
;
	inxix			; point after terminator
	ora	a		; clear carry
	ret
;
;
;	getstrch:	get one string character into A
;
getstrch:
	ldx	a,0
	ora	a
	jz	cmderr		; error if end of line
	inxix
	cpi	''''
	rnz			; ready if no delimiter
	ldx	a,0
	cpi	''''
	jnz	cmderr		; error if not paired
	inxix
	ret
;
;
;	skipsp:		skip spaces in input string
;
skipsp:
	ldx	a,0
	cpi	' '
	jrz	skipsp1
	cpi	'_'
	jrnz	testch
skipsp1:
	inxix
	jr	skipsp
;
;
;	skipsep:	skip spaces and ',' in input string
;
skipsep:
	ldx	a,0
	cpi	' '
	jrz	skipsep1
	cpi	'_'
	jrz	skipsep1
	cpi	','
	jrnz	testch
skipsep1:
	inxix
	jr	skipsep
;
;
;	getch:		get a character from the input string, skip '_'
;
getch:
	call	testch
	rz			; dont increment if end of string
	inxix
	ret
;
;	testch:		test the character from the input string, skip '_'
;
testch:
	call	stestch
	rz
	cpi	'_'
	rnz
	inxix
	jr	testch
;
;
;	sgetch:		get a character from the input string
;
sgetch:	
	call	stestch
	rz			; dont increment if end of string
	inxix
	ret
;
;	stestch:	test the character from the input string
;
stestch:
	ldx	a,0
	ora	a
	rz
	cpi	'a'
	rc
	cpi	'z'+1
	jrc	testcupc
	ora	a
	ret
testcupc:
	adi	'A'-'a'
	ret
;
;
;------------------------------------------------------------------------------
;
;
;	readstring:	read input string
;
;		exit:	IX = start of string
;			skipsp called
;
readstring:
	lxix	string
	push	b
	lxi	h,string
	mvi	b,0		; length
;
rdstloop:
	call	rdchar
	ani	7fh		; clear parity bit
	cpi	7fh		; DEL ?
	jrz	rdstdel
	cpi	08h		; BS ?
	jrz	rdstdel
	cpi	0dh		; CR ?
	jrz	rdstend
	cpi	0ah		; LF ?
	jrz	rdstloop	; ignore LF
	cpi	09h		; TAB ?
	jrnz	rdstsp
	mvi	a,' '		; replace by ' '
rdstsp:
	cpi	20h
	jrc	rdstbeep	; beep if other control character
rdstok:
	mov	m,a		; store
	mov	a,b
	cpi	79
	jrz	rdstbeep	; beep if line filled
	mov	a,m
	call	wrchar		; echo character
	inx	h
	inr	b
	jr	rdstloop
;
rdstbeep:
	mvi	a,7		; BEL
	call	wrchar
	jr	rdstloop
;
rdstdel:
	mov	a,b
	ora	a
	jrz	rdstloop	; no action if at start of line
	mvi	a,8
	call	wrchar		; BS
	call	space
	mvi	a,8		; BS
	call	wrchar
	dcx	h
	dcr	b
	jr	rdstloop
;
rdstend:
	call	crlf		; echo crlf
	xra	a
	mov	m,a		; terminate
	inx	h
	mov	m,a		; one more to be safe
	dcx	h
	mov	a,b
	jrz	rdstexit	; ret if zero length string
rdsttrunc:
	dcx	h		; point to last char
	mov	a,m
	cpi	' '		; truncate space at the end
	jrnz	rdstexit
	mvi	m,0
	djnz	rdsttrunc	; again
;
rdstexit:
	pop	b
	jmp	skipsp
;
;
;------------------------------------------------------------------------------
;
;	bytestring:	process input line into a string of bytes
;
;		entry:	IX = string pointer
;
;		exit:	IX = bytestring-pointer
;			B = IX-1 = length of string
;			Carry set if no values
;
bytestring:
	lxiy	string			; destination
	mvi	b,0			; number of bytes
;
byteslp:
	call	skipsep
	jrz	bytesend		; ready if end of input line
	cpi	''''
	jrz	bytesstr		; branch if string
	push	b
	call	expression		; try expression
	pop	b
	jc	cmderr			; error if something else
	sty	l,0			; store lower byte only
	inxiy
	inr	b
	jr	byteslp
;
bytesend:
	lxix	string
	stx	b,-1
	mov	a,b
	ora	a
	rnz				; ok if nonzero length
	stc				; signal nothing there
	ret
;
bytesstr:
	inxix
bytesstrlp:
	call	getstrch	; get character
	sty	a,0		; into result
	inxiy
	inr	b
	ldx	a,0		; next char
	cpi	''''
	jrnz	bytesstrlp	; ok if not terminator
	cmpx	1		; next char a '''' too ?
	jrz	bytesstrlp	; then loop
;
	inxix			; point after terminator
	jr	byteslp
;
;
;------------------------------------------------------------------------------
;
;	rdregval:	read register value
;
;		exit:	HL = value
;			DE = variable address
;			 C = size (0 = 16-bit)
;			Carry set if no register
;
rdregval:
	lxi	d,0
	call	skipsp
	stc
	rz			; no reg if end of line
	cpi	'Y'		; Variables don't need a lead-in
	jrz	rdregvy
;
	IF	hilo
	cpi	'H'		; special var High
	jrz	rdregvh
	cpi	'L'		; special var Low
	jrz	rdregvl
	cpi	'M'		; special var Max
	jrz	rdregvm
	cpi	'T'		; special var Top
	jrz	rdregvt
	ENDIF
;
	IF	extended
	cpi	'X'		; special var eXtended addr
	jrz	rdregvx
	ENDIF
;
	cpi	'$'
	jrz	rdregvpc
	cpi	'R'		; reg-val lead in character
	stc
	rnz			; no reg if no lead-in
	inxix			; skip lead-in
	call	rdregister
	jc	cmderr		; error if no register
rdregvrdy:
	mov	e,m		; get value
	inx	h
	mov	d,m
	dcx	h		; restore address
	xchg			; address into DE, value into HL
	mvi	c,0		; 16-bit
	ani	3fh
	cpi	20h
	rnc			; ready if 16-bit reg
	mov	c,a		; mark 8-bit
	cpi	17h		; R ?
	cz	rdregvr		; branch if R
	xra	a		; clear carry
	mov	h,a		; upper byte = 0 for 8-bit reg
	ret	
;
rdregvpc:
	call	getch
	lxi	h,regpc
	mvi	a,23h
	jr	rdregvrdy
;
	IF	extended
rdregvx:
	lxi	h,cbank
	pushix
	call	getch		; skip H/L
	mvi	a,1fh
	push	psw
	jr	rdregvxck
	ENDIF
;
	IF	hilo
rdregvm:
	lxi	h,maxval
	jr	rdregvlh
rdregvh:
	lxi	h,highval
	jr	rdregvlh
rdregvt:
	lxi	h,topval
	jr	rdregvlh
;
rdregvl:
	lxi	h,lowval
rdregvlh:
	pushix
	call	getch		; skip H/L
;
	ENDIF
rdregvck:
	mvi	a,3bh
	push	psw
rdregvxck:
	call	testch		; get next
	call	isspecial
	jrc	rdregvn1	; no reg if not a special follows
	pop	psw
	pop	d		; discard old IX
	jr	rdregvrdy
;
rdregvy:
	pushix
	call	getch		; skip Y
	call	getch		; get digit
	call	isdigit
	jrc	rdregvnone	; no reg if not a digit
	sui	'0'
	add	a
	mov	e,a
	mvi	d,0
	lxi	h,variables
	dad	d
	jr	rdregvck
;
rdregvn1:
	pop	psw
rdregvnone:
	popix			; restore old character pointer
	stc
	ret			; ret with error indication
;
rdregvr:
	ldar
	mov	l,a
	lxi	d,0		; R has no address
	ret
;
;
;	rdregister:	read register name
;
;		entry:	IX = string pointer
;
;		exit:	Carry set if no register name
;			HL = register address
;			A = register designation (1x for 8-bit, 2x for 16-bit)
;				10=B, 11=C, 12=D, 13=E, 14=H, 15=L, 16=I,
;				17=R, 18=A, 19=F, 1A=IFF
;				20=BC, 21=DE, 22=HL, 23=SP, 24=AF, 25=IX,
;				26=IY, 27=PC
;			    Bit 7 is set if alternate register
;
rdregister:
	call	skipsp
	stc
	rz			; ready if end of string
;
rdreg10:
	pushix			; save start pos
	mvi	b,0		; length
	mvi	d,0		; mark no alternate
;
rdreg20:
	call	getch
	jrz	rdreg30		; branch if end of line
	cpi	''''
	jrz	rdreg25		; branch if alternate-marker
	call	isletter
	jrc	rdreg30		; branch if no letter
	inr	b
	jr	rdreg20		; loop if letter
;
rdreg25:
	mvi	d,80h		; mark alternate
	call	testch
	call	isspecial
	jrc	rdregnoiff	; no reg if no special follows
	jr	rdreg35
;
rdreg30:
	ora	a
	jrz	rdreg35		; ok if end of line
	call	isdigit
	jrnc	rdregnoiff	; not a register if digit follows
;
rdreg35:
	popix			; back to the start
	mov	a,b
	ora	a
	stc
	rz			; no reg if 0 chars
	cpi	3
	jrc	rdreg40		; ok if <= 2 chars
	stc
	rnz			; exit if > 3 chars
	pushix
	lxi	h,iffstr
	mvi	b,3
iffloop:
	call	getch		; check for 'IFF'
	cmp	m
	jrnz	rdregnoiff
	inx	h
	djnz	iffloop
	mov	a,d
	ora	a
	jrnz	rdregnoiff	; there is no alternate IFF
	pop	h		; discard old IX
	mvi	a,1ah
	lxi	h,regiff	; return IFF
	ret			; ready for IFF
;
rdregnoiff:
	popix
rdregnone:
	stc			; mark no register
	ret
;
rdreg40:
	dcr	a
	jrnz	rdreg16bit	; check for 16-bit reg if 2 chars
	call	testch
	lxi	h,reg8nam
	lxi	b,10		; 10 chars in reg8nam
	ccir
	stc
	rnz			; no register
;
rdreg8bit:
	lxi	b,reg8nam
	ora	a
	dsbc	b		; calculate offset
	mov	a,l
	dcr	a		; offset in reg8nam
	lxi	h,regbc		; start of registers
	bit	7,d		; alternate reg ?
	jrz	rdreg8noalt	; branch if not alternate
	cpi	6		; I/R ?
	jrc	rdreg8alt	; ok if not
	cpi	8
	rc			; exit, no alternate for I/R
rdreg8alt:
	lxi	h,altbc		; address alternate
	inxix			; and skip ''''
;
rdreg8noalt:
	inxix			; skip reg name
	xri	1		; swap 0/1
	mov	c,a
	mvi	b,0
	xri	1
	cpi	6		; I/R ?
	jrz	reg8i
	cpi	7
	jrnz	reg8na10
	lxi	h,0		; R has no address
	jr	reg8na20
reg8i:
	lxi	h,regi		; I has special address
	jr	reg8na20
;
reg8na10:
	dad	b		; address of register in save area
;
reg8na20:
	ori	10h
	ora	d		; or in alt-flag
	ret
;
;
rdreg16bit:
	pushix
	call	getch
	mov	c,a
	call	getch
	mov	e,a
	cpi	'C'			; PC ?
	jrnz	rdr1610
	mov	a,c
	cpi	'P'
	jrnz	rdr1610			; branch if not PC
	mov	a,d
	ora	a
	jrnz	rdregnoiff		; no alternate PC
	mvi	a,27h
	lxi	h,regpc
	pop	d			; discard old IX
	ret				; ready for PC
;
rdr1610:
	lxi	h,r16nam
	mvi	b,7
rdr1620:
	mov	a,c
	cmp	m			; search name in r16nam
	inx	h
	jrnz	rdr1625
	mov	a,e
	cmp	m
	jrz	rdr16fnd		; branch on match
rdr1625:
	inx	h
	djnz	rdr1620
	jmp	rdregnoiff		; not found, not a register
;
rdr16fnd:
	mvi	a,7
	sub	b
	mov	c,a		; register number
	lxi	h,regbc
	mov	a,d
	ora	a
	jrz	rdr1640		; jump if not alternate
	mov	a,c
	cpi	3
	jrc	rdr1635
	cpi	4
	jnz	rdregnoiff	; no alternate for SP, IX, IY
rdr1635:
	lxi	h,altbc
	inxix			; skip alt-marker
rdr1640:
	mvi	b,0		; register number in BC
	dad	b		; point to register
	dad	b
	mov	a,c		; reg number
	ori	20h		; mark 16-bit reg
	ora	d		; or in alt-flag
	pop	d		; discard old ix
	ret
;
;------------------------------------------------------------------------------
;
isdigit:
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	ret
;
isletter:
	cpi	'A'
	rc
	cpi	'Z'+1
	cmc
	ret
;
isspecial:
	call	isdigit
	cmc
	rc
	call	isletter
	cmc
	ret
;
;
iscontrol:
	ani	7fh
	cpi	7fh
	rz				; is control char if = 7f
	cpi	20h
	cmc				; set carry for char >= 20h
	ret
;
;------------------------------------------------------------------------------
;
	dseg
;
temp		ds	2
strlen		ds	1		; string length storage for bytestring
string		ds	81
;
	end

