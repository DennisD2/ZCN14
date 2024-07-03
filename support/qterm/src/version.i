; version.i - keep the version in one place

.var	no	0
.var	yes	! no

.var	major	4
.var	minor	3
.var	rev	'e'
.var	subver	0

;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
.var	dg	yes		; set this no for release versions
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.macro	year
	db	'1991'
.endm

.macro	version
.if	major >= 100
	db	major / 100 + '0'
.endif
.if	major >= 10
	db	[major / 10] % 10 + '0'
.endif
	db	major % 10 + '0'
	db	'.'
.if	minor >= 100
	db	minor / 100 + '0'
.endif
.if	minor >= 10
	db	[minor / 10] % 10 + '0'
.endif
	db	minor % 10 + '0', rev
.if	subver
	db	' ('
.if	subver >= 1000
	db	subver / 1000 + '0'
.endif
.if	subver >= 100
	db	[subver / 100] % 10 + '0'
.endif
.if	subver >= 10
	db	[subver / 10] % 10 + '0'
.endif
	db	subver % 10 + '0', ')'
.endif
.endm
