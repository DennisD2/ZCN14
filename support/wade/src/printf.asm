	title	'PRINTF: Formatted output routine'
;
;	Last edited	85-03-17	Wagner
;
;
;	Used for messages inside BIOS, but also useful for user 
;	written assembly programs (set "bios" to false).
;	Use is similar to "C"-printf, but watch out for 
;	pitfalls (deref, see below).
;
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
;------------------------------------------------------------------------------
;
;	?prntf:		formatted console output.
;	?lprnt:		formatted printer output (for BIOS/DIRECT: console)
;	?sprnt:		formatted string output.
;
;		entry:	Parameter list placed after call as follows:
;
;			CALL	?prntf / ?lprnt / ?sprnt
;			JMP	xxx		; jump around parameters
;	?sprnt only:	DW	destination string address
;			DW	conversion string address
;			DW	param 1
;			...
;
;			Use macro printf for generation (see "PRINTF.LIB").
;			The instruction after the call must be 3 bytes long 
;			(no relative jump allowed).
;
;			The ?sprnt entry will insert the string at the
;			specified destination address, where the first two
;			bytes will receive the resulting string length
;			(not counting the terminating zero byte).
;			This string length may be nonzero upon entry, and then
;			specifies the offset to the destination address
;			where the first character is to place.
;
;		exit:	-
;
;		uses:	-  (up to 20 bytes of stack space)
;
;	Printf Macro call:
;
;		printf	'Contents of addr %w: %@wH -> %@@s\n',<adr,adr,adr>
;		sprintf	dest,'Dest is located at %w$',dest
;
;	Conversion specification:
;
;		'%' <deref ...> <fieldwidth> conversion
;	   or	'\' specialchar
;
;	Deref:
;		@ = dereferencing
;		+ = indexing
;		# = indexed dereferencing
;		in any combination.
;
;		No deref or index: immediate value (meaningless for string).
;
;		Deref: parameter is the address of the value.
;
;		Index: the next parameter is added to the value
;		after any dereferencing of the index value. Indexing implies
;		that the obtained sum is the address of the value.
;
;		Indexed deref (only meaningful after index):
;		the pointer obtained after indexing is dereferenced.
;		
;	For use in the fill-conversion, the special character '&' may be
;	used to designate the current output position:
;
;		%&10f*	means: subtract the current position counter
;			from 10, output '*' the resulting number of times.
;
;	The character '&' may not be combined with dereferencing. 
;
;	Example:
;
;		ORG	1234h
;
;	adr1:	DW	byt1	; 1234h
;	adr2:	DW	byt2	; 1236h
;	adr3:	DW	byt3	; 1238h
;
;	adr4:	DW	adr1	; 123Ah
;
;	byt1:	DB	1	; 123Ch
;	byt2:	DB	2
;	byt3:	DB	3
;		DB	4
;		DB	5
;
;	idx:	DW	2
;
;		printf	'%w\n',adr1		-> 1234 addr of adr1
;		printf	'%@w\n',adr1		-> 123C content of adr1
;		printf	'%@@x\n\n',adr1		-> 01   cont of cont of adr1
;
;		printf	'%+x\n',<byt1,1>	-> 02	contents of (byt1 + 1)
;		printf	'%+@x\n',<byt1,idx>	-> 03	byt1 + @idx = byt1 + 2
;		printf	'%@+@x\n',<adr1,idx>	-> 03	@adr1=byt1 + @idx
;		printf	'%@+@+x\n\n',<adr1,idx,1> -> 04 @adr1=byt1 + @idx + 1
;
;		printf	'%+#x\n',<adr1,4>	-> 03	@(adr1 + 4)=@adr3=byt3
;		printf	'%+@#x\n',<adr1,idx>	-> 02	@(adr1 + @idx) = @adr2
;							= byt2
;		printf	'%@+@#+x\n',<adr4,idx,3> -> 05  @(@adr4 + @idx) + 3
;							= @(adr1 + @idx) + 3
;							= @adr2 + 3 = byt2 + 3
;
;
;	Conversion:
;
;		%x - hex output (byte or byte string).
;		%w - hex output (word or multiple words).
;		%b - decimal output (byte, unsigned).
;		%d - decimal output (word, signed).
;		%u - decimal output (word, unsigned).
;		%s - string output (must be zero-terminated except if length
;		     is known and specified as fieldlength).
;		%t - string output, first byte is string length.
;		%v - string output, next character in conversion string
;		     specifies termination character.
;		%c - character output.
;		%a - character output, next character in conversion string
;		     is added to value before output.
;		%f - fill, next character in conversion string is output,
;		     value specifies number of times to output char (<= 255)
;
;		any other char: error ('?' is printed).
;
;	Field width (maximum is 255):
;
;		hex: 	Number of hex digits printed (no space filling).
;			If an odd number is used, only the upper nibble of
;			the last byte is printed.
;			Note that every 2 bytes are reversed for %w.
;			Default is 2 for %x, 4 for %w, 0 means default.
;
;		dec:	Result is right adjusted in the field.
;			All significant digits will be printed if field width
;			is smaller than necessary.
;			Default is 0.
;
;		string:	Output is left adjusted.
;			The string will be truncated if the field width is
;			smaller than the string length.
;			Default is printing up to a zero byte for %s or
;			up to the count for %t, 0 means default.
;			%t-output will be terminated on a zero byte, too.
;			For %v, the fieldlength specifies the maximum length
;			of the string, no padding will take place.
;			%v-output will not terminate on a zero byte.
;
;		char:	Character is right adjusted.
;			Default is 1, 0 means default.
;
;		fill:	If specified, the value is subtracted from the
;			fieldwidth. If omitted or zero, the value is used
;			as is. If the value is larger than a nonzero 
;			fieldwidth, nothing will be output.
;
;	Special characters:
;
;		\r	carriage return
;		\n	carriage return + line feed
;		\l	line feed
;		\h	backspace
;		\g	bell
;		\%	%
;		\\	\
;		\dd	with dd = one or two hex digits: value of dd
;
;		\&	Reset position counter to zero, no output
;
;		any other char: error ('?' is printed).
;
;	Parameters:
;
;		One parameter must be specified for each %-conversion and
;		index except for %&, else meaningless values will be output.
;
;	Code Example:
;
;		CALL	?prntf
;		JMP	xxx
;		DW	string
;		DW	dstr
;		DW	dstr
;	string	DB	'String at %wH: "%@s"\n',0
;
;	dstr	DB	'Hello'
;
;	Example for %v-string output to print a filename without spaces
;	from an fcb and fill to a total length of 20 bytes:
;
;		printf	'%@c:%@8v .%@3v %&20f ',<fcb,fcb+1,fcb+9>
;
;------------------------------------------------------------------------------
;
	public	?prntf
	public	?lprnt
	public	?sprnt
;
;
true	equ	-1
false	equ	not true
;
direct	equ	false		; set true for direct port i/o
bios	equ	false		; set to false for use outside of BIOS
mpm	equ	false		; set true for use in MP/M XIOS
;
;
	IF	direct
	maclib	ports
	ENDIF
;
	maclib	z80
;
	IF	bios AND NOT mpm
	dseg			; in banked memory if used in BIOS
	ELSE
	cseg			; code space if MPM or not for use in BIOS
	ENDIF
;
;------------------------------------------------------------------------------
;
?sprnt:
	xthl			; get retaddr, save hl
	push	h		; push back retaddr
	push	psw
	push	b
	push	d
	mvi	a,0ffh
	sta	sprint		; mark string destination
	inx	h		; second byte of JMP
	inx	h		; third
	inx	h		; start of parameter list
	mov	e,m		; destination string address
	inx	h
	mov	d,m
	inx	h
	xchg			; HL points to destination string.
	shld	strlen		; store as length pointer
	mov	c,m
	inx	h
	mov	b,m		; current length
	inx	h		; point after length
	dad	b		; add current length to dest addr
	mov	a,c
	sta	position	; use lower byte as position
	shld	strptr		; store as pointer
	xchg			; get pointer to string into hl again
	jr	prtcom		; and continue in common part
;
?lprnt:
	push	psw
	mvi	a,5		; list output
	jr	plcom
;
?prntf:
	push	psw
	mvi	a,2		; console out
plcom:
	sta	sprint		; set output direction
	pop	psw
	xthl			; get retaddr, save hl
	push	h		; push back retaddr
	push	psw
	push	b
	push	d
	inx	h		; second byte of JMP
	inx	h		; third
	inx	h		; start of parameter list
	xra	a
	sta	position	; clear position counter
prtcom:
	mov	e,m		; string address
	inx	h
	mov	d,m
	inx	h
	xchg			; DE now contains first parameter address
				; HL points to string.
;
main:
	mov	a,m		; get string char
	inx	h
	ora	a		; end of string ?
	jrz	return		; ready if zero byte.
	cpi	'%'		; conversion marker ?
	jrz	convert		; then go format
	cpi	'\'		; special char ?
	jrz	special		; then go process
normal:
	call	output		; else output the character
	jr	main
;
return:
	pop	d
	pop	b
	pop	psw
	pop	h
	xthl
	ret
;
;
special:
	mov	a,m
	inx	h
	call	tolower
	cpi	'r'
	jrz	ocr
	cpi	'l'
	jrz	olf
	cpi	'n'
	jrz	onl
	cpi	't'
	jrz	otb
	cpi	'b'
	jrz	obs
	cpi	'h'
	jrz	obs
	cpi	'&'
	jrz	resposn
	cpi	'g'
	jrnz	sphex
	mvi	a,7
	jr	normal
;
resposn:
	xra	a
	sta	position
	jr	main
;
olf:
	mvi	a,0ah
	jr	normal
onl:
	mvi	a,0ah
	call	output
ocr:
	mvi	a,0dh
	jr	normal
obs:
	mvi	a,08h
	jr	normal
otb:
	mvi	a,09h
	jr	normal
;
sphex:
	call	aschex
	jrc	error		; skip field if unknown char
sphex0:
	mov	c,a
	mov	a,m
	call	aschex
	jrnc	sphex1
	mov	a,c
	jr	normal		; if one hex digit only
sphex1:
	inx	h
	mov	b,a
	mov	a,c
	rlc
	rlc
	rlc
	rlc
	ora	b		; two hex digits
	jr	normal		; go output
;
error:
	dcx	h		; go back one char
	mvi	a,'?'
	jr	normal		; go output '?'
;
;
convert:
	pushix			; save ix
	push	h
	popix			; string pointer into ix
	push	d		; save parameter pointer
	xchg			; and put into hl
	lxi	b,0
	mvi	a,0ffh
	sta	idxcnt
;
conref:
	ldx	a,0		; get conversion spec
	inxix
	cpi	'&'		; position ref ?
	jrz	refposn
	cpi	'@'		; deref ?
	jrz	ref
	cpi	'#'		; indexed deref ?
	jrnz	conv1		; no deref if not
	dad	b		; add accumulated value and use as pointer
	lxi	b,0
ref:
	mov	e,m		; get value of parameter
	inx	h
	mov	d,m		; into de
	xchg			; and use as pointer
	jr	conref		; loop
;
conv1:
	cpi	'+'		; indexed ?
	jrnz	conv2
	push	h
	lxi	h,idxcnt
	inr	m
	pop	h
	jrnz	conv11		; skip implied deref if not first time
	mov	e,m		; else get value pointed to by hl
	inx	h
	mov	d,m
	xchg
conv11:
	dad	b		; add in last value
	mov	b,h
	mov	c,l		; into bc
	pop	h		; get param pointer
	inx	h
	inx	h
	mov	e,m
	inx	h		; get next param
	mov	d,m		; value into de
	dcx	h
	push	h		; save updated param pointer
	xchg			; param value into de
	jr	conref		; go deref
;
refposn:
	pop	h		; param pointer
	dcx	h		; decrease to compensate for increase at end
	dcx	h
	push	h
	lxi	h,position
	jr	conref
;
conv2:
	dad	b		; add value
	xchg			; pointer into de
	pushix
	pop	h		; string pointer into hl
	mvi	c,0		; default fieldwidth
conv3:
	cpi	'0'		; digit ?
	jrc	nodig
	cpi	'9'+1
	jrnc	nodig
	sui	'0'
	mov	b,a		; save
	mov	a,c
	add	a		; * 2
	add	a		; * 4
	add	c		; * 5
	add	a		; * 10
	add	b		; + value
	mov	c,a		; into c
	mov	a,m		; get next char
	inx	h
	jr	conv3
nodig:
	push	h		; save string addr
	call	tolower		; lower case letters only, convert
	lxi	h,convtab
	mvi	b,cvtblen
fndconv:
	cmp	m
	inx	h
	jrz	cfound
	inx	h
	inx	h
	djnz	fndconv
;
	pop	h
	pop	d		; unchanged param pointer
	popix
	jmp	error		; unknown conversion
;
cfound:
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	mov	b,c		; b = c = fieldwidth
	mov	a,c
	ora	a		; set fieldwidth condition code
	call	ipchl		; enter routine
;
convex:
	pop	h		; restore string address
	pop	d
	inx	d
	inx	d		; point to next parameter
	popix			; restore ix
	jmp	main
;
ipchl:	pchl
;
convtab:			; note: sorted in ascending order
	db	'a'
	dw	achrout
	db	'b'
	dw	bytout
	db	'c'
	dw	chrout
	db	'd'
	dw	decout
	db	'f'
	dw	fillout
	db	's'
	dw	strout
	db	't'
	dw	ttrout
	db	'u'
	dw	unsout
	db	'v'
	dw	vstrout
	db	'w'
	dw	wrdout
	db	'x'
	dw	hexout
cvtblen	equ	($-convtab)/3
;
;
achrout:
	mvi	c,1
	jr	chro0
;
chrout:
	mvi	c,0
chro0:
	jrnz	chro1
	mvi	b,1		; default field width
chro1:
	dcr	b
	jrz	chro2
	mvi	a,' '
	call	output
	jr	chro1
chro2:
	ldax	d
	dcr	c
	jnz	output		; jump if no offset
	pop	h
	xthl			; get conversion string pointer
	add	m		; add character
	inx	h		; point to next
	xthl
	push	h
	jmp	output
;
fillout:
	ldax	d		; fieldwidth value
	jrz	fillout1	; ok if default
	mov	c,a
	mov	a,b
	sub	c		; subtract from specified fieldwidth
	jrnc	fillout1	; ok if smaller 
	xra	a		; else output nothing
fillout1:
	mov	b,a
	ora	a		; condition code
	pop	h
	xthl			; get conversion string pointer
	mov	a,m
	inx	h
	xthl
	push	h
	rz			; ready if nothing to output
filloutl:
	push	psw
	call	output
	pop	psw
	djnz	filloutl
	ret
;
;
ttrout:
	xchg
	mvi	e,0		; terminator
	mov	b,m		; max chars = length
	inx	h
	jrnz	ttro1
	mov	c,b		; fieldwidth = max chars = length 
	jr	stro1
ttro1:
	mov	a,c
	cmp	b
	jrnc	stro1		; ok if fieldwidth >= length
	mov	b,c		; else length = fieldwidth
	jr	stro1
;
vstrout:
	pop	h		; retaddr
	xthl			; string addr
	mov	a,m		; terminator
	inx	h
	xthl
	push	h		; restore stack
	xchg
	mov	e,a
	mvi	c,0
	jr	stro0
;
strout:
	xchg			; parameter into hl
	mvi	e,0
stro0:
	jrnz	stro1
	mvi	b,0ffh		; max chars
stro1:
	mov	a,m
	inx	h
	cmp	e		; end of string ?
	jrz	stro2
	call	output		; output the character
	dcr	c
	jp	stro11
	mvi	c,0
stro11:
	djnz	stro1
;
stro2:
	dcr	c
	rm
	mvi	a,' '
	call	output
	jr	stro2
;
;
wrdout:
	jrnz	wrdo1
	mvi	b,4		; default field width
wrdo1:
	inx	d
	call	hexbyt
	rz
	dcx	d
	call	hexbyt
	rz
	inx	d
	inx	d
	jr	wrdo1
;
;
hexout:
	jrnz	hexo1
	mvi	b,2		; default field width
hexo1:
	call	hexbyt
	rz
	inx	d
	jr	hexo1
;
hexbyt:
	ldax	d
	rrc
	rrc
	rrc
	rrc
	call	hexdig
	rz
	ldax	d
hexdig:
	ani	0fh
	adi	'0'
	cpi	'9'+1
	jrc	hdo
	adi	'A'-'0'-10
hdo:
	call	output
	dcr	b
	ret
;
;
bytout:
	ldax	d
	mov	e,a		; load lower byte
	xra	a
	mov	d,a		; clear upper byte
	sta	sign		; no sign
	mvi	c,1		; no. of digits
	jr	deco2
;
;
unsout:
	xchg
	mov	e,m
	inx	h
	mov	d,m
	xra	a
	sta	sign
	mvi	c,1		; no. of digits
	jr	deco2
;
;
decout:
	xchg
	mov	e,m
	inx	h
	mov	d,m
	mvi	c,1		; no. of digits
	mov	a,d
	sta	sign
	ora	a
	jp	deco2		; skip if positive
	lxi	h,0
	dsbc	d		; 16-bit complement
	xchg
	inr	c		; space for minus sign
;
deco2:				; determine number of significant digits
	lxi	h,-10
	dad	d
	jrnc	deco3
	inr	c
	lxi	h,-100
	dad	d
	jrnc	deco3
 	inr	c
	lxi	h,-1000
	dad	d
	jrnc	deco3
	inr	c
	lxi	h,-10000
	dad	d
	jrnc	deco3
	inr	c
deco3:
	mov	a,b		; field width
	sub	c		; space fill ?
	jrz	deco4
	jrc	deco4		; no space fill if field width <= significant
	mov	b,a		; else fill
decosp:
	mvi	a,' '
	call	output
	djnz	decosp
;
deco4:
	lda	sign
	ora	a
	jp	deco5
	mvi	a,'-'		; output sign
	call	output
deco5:
	xchg			; get value into hl
	mvi	b,'0'		; mark zero suppression
	lxi	d,-10000
	call 	decdig
	lxi	d,-1000
	call	decdig
	lxi	d,-100
	call	decdig
	lxi	d,-10
	call	decdig
	dcr	b		; no zero suppression for last digit
	lxi	d,-1
;				; fall through to decdig
decdig:
	mvi	c,'0'-1
	push	psw		; dummy push
decdigl:
	pop	psw
	push	h		; remainder
	inr	c
	dad	d
	jrc	decdigl		; subtract until no borrow
	mov	a,c
	cmp	b		; zero suppression ?
	jrz	supzer
	dcr	b		; no further zero suppression
	call	output		; output the digit
supzer:
	pop	h		; remainder
	ret
;
;
tolower:
	cpi	'A'
	rc
	cpi	'Z'+1
	rnc
	adi	'a'-'A'
	ret
;
;
aschex:
	cpi	'0'
	rc
	cpi	'9'+1
	jrnc	asch1
	sui	'0'
	ret
asch1:
	call	tolower
	cpi	'a'
	rc
	cpi	'g'
	jrnc	asch2
	sui	'a'-10
	ret
asch2:
	stc
	ret
;
;
	IF	bios
;
	extrn	?pchr
output:
	push	h
	lxi	h,position
	inr	m
	pop	h
	push	psw
	lda	sprint
	inr	a
	jrz	out1		; jump if string output
	pop	psw		; list output goes to console for BIOS
	jmp	?pchr		; directly jump to BIOS char out routine
;
out1:
	pop	psw
	push	h
	lhld	strptr		; destination pointer
	mov	m,a		; insert the character
	inx	h		; increase dest pointer
	shld	strptr		; store back
	lhld	strlen		; load string length address
	inr	m		; increase
	jrnz	outret		; redy if no overflow
	inx	h		; increase next byte
	inr	m
outret:
	pop	h
	ret
;
	ELSE
;
output:
	push	b
	push	d
	push	h
	lxi	h,position
	inr	m
	mov	e,a
	lda	sprint		; sprintf ?
	inr	a
	jrz	out1		; branch if string destination
;
	IF	direct
;
outwt:
	in	s2bc
	ani	4		; Tx Buffer empty ?
	jrz	outwt
	mov	a,e
	out	s2bd
;
	ELSE
;
	dcr	a
	mov	c,a		; BDOS function number
	call	5		; call BDOS
;
	ENDIF
;
outret:
	pop	h
	pop	d
	pop	b
	ret
;
out1:
	lhld	strptr		; destination pointer
	mov	m,e		; insert the character
	inx	h		; increase dest pointer
	shld	strptr		; store back
	lhld	strlen		; load string length address
	inr	m		; increase
	jrnz	outret		; redy if no overflow
	inx	h		; increase next byte
	inr	m
	jr	outret
;
	ENDIF
;
	IF	NOT bios
	DSEG			; data segment if not BIOS
	ENDIF
;
sprint	ds	1
strptr	ds	2
strlen	ds	2
;
;
sign	ds	1
idxcnt	ds	1
position ds	1
;
	public	?pfraf,?pfra,?pfrbc,?pfrb,?pfrde,?pfrd
	public	?pfrhl,?pfrh,?pfrix,?pfriy,?pfrsp
;
?pfraf	ds	1
?pfra	ds	1
?pfrbc	ds	1
?pfrb	ds	1
?pfrde	ds	1
?pfrd	ds	1
?pfrhl	ds	1
?pfrh	ds	1
?pfrix	ds	2
?pfriy	ds	2
?pfrsp	ds	2
;
	end

