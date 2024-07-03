; kermit.i - definitions for kermit file transfer code

.var	MAXPSIZ	90	; Maximum packet size
.var	MINPSIZ	20	; minimum packet size
.var	SOH	1	; Start of header
.var	DEL	0x7f	; Delete

.var	MAXTRY	10	; Times to retry a packet
.var	MYQUOTE	'#'	; Quote character I will use
.var	MYHIBIT	'&'	; char I use for hi-bit sending
.var	MYPACK	'~'	; char I use for repeat packing
.var	MYPAD	0	; Number of pad characters I need
.var	MYPCHAR	0	; Padding character I need (NULL)

.var	MYTIME	12	; Seconds before I'm to be timed out
.var	MAXTIM	30	; Maximum timeout interval
.var	MINTIM	4	; Minumum timeout interval

.var	MYEOL	'\r'	; End-Of-Line character I need
