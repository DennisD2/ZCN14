; vars.i - global variables for qterm

.var	buffin	10		; console buffered input
.var	versn	12		; get operating system version
.var	rescpm	13		; reset bdos to avoid R/O disk problems
.var	seldrv	14		; select drive
.var	open	15		; open a file
.var	close	16		; close a file
.var	srchf	17		; find the first occurance
.var	srchn	18		; find the next occurance
.var	erase	19		; erase file
.var	read	20		; read sequential
.var	write	21		; write sequential
.var	create	22		; create a file
.var	rename	23		; rename file
.var	getdrv	25		; get current drive
.var	setdma	26		; set the dma address
.var	dpbadr	31		; get disk parameter block address
.var	gsuser	32		; get or set user code
.var	redrnd	33		; read random
.var	cfsize	35		; compute the filesize
.var	logdrv	37		; reset individual drive

.var	fcb	0x5b		; fcb address
.var	ipbuf	0x80		; input buffer
.var	buffer	0x80		; buffer used for wildcard scans
.var	cmdlin	0x80		; where the command tail lives

.var	op_bit	1		; output modem chars flag
.var	mat_bit	2		; print match messages flag
.var	lf_bit	4		; print looking for messages flag