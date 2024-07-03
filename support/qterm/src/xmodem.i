; xmodem.i - header file for xmodem file transfer code

.var	FALSE	0
.var	TRUE	1

; ASCII Constants

.var	SOH	001
.var	STX	002
.var	ETX	003
.var	EOT	004
.var	ENQ	005
.var	ACK	006
.var	LF	'\n'
.var	CR	'\r'
.var	NAK	025
.var	SYN	026
.var	CAN	030
.var	ESC	'\e'

; XMODEM Constants

.var	TIMEOUT	-1
.var	ERRMAX	20
.var	NAKMAX	2
.var	RETRMX	8
.var	CRCSW	3
.var	KSWMAX	5
.var	BBUFSIZ	1024
.var	NAMSIZ	11
.var	CTRLZ	032
.var	CRCCHR	'C'
.var	BADNAM	'u'
