# modified TED Makefile for ZCN build
#
# Given the way VSIZE is used heavily in scrn.mac, and the high speed
# of assembling, I changed this to work as basically just a dumb script.
# This is ugly but makes dealing with the separate NC1x0/NC200/VT100
# versions much easier.
#
# -rjm

# Path to Linux utilities
ZXCC    = zxcc

# Path to CP/M utilities
ZSM4    = zsm4.com
DRLINK  = cpm3link.com

all: ted.com ted200.com tedvt.com

SRCS = main.mac \
	termdef.mac \
	fileio.mac \
	scrn.mac \
	cmds.mac \
	cpmio.mac

ted.com: $(SRCS) ted.inc tsnc100.inc
	cp tsnc100.inc termsel.inc
	for i in $(SRCS); do $(ZXCC) $(ZSM4) -=$$i ; done
	$(ZXCC) $(DRLINK) -"ted=termdef,main,fileio,scrn,cmds,cpmio"

ted200.com: $(SRCS) ted.inc tsnc200.inc
	cp tsnc200.inc termsel.inc
	for i in $(SRCS); do $(ZXCC) $(ZSM4) -=$$i ; done
	$(ZXCC) $(DRLINK) -"ted200=termdef,main,fileio,scrn,cmds,cpmio"

tedvt.com: $(SRCS) ted.inc tsvt100.inc
	cp tsvt100.inc termsel.inc
	for i in $(SRCS); do $(ZXCC) $(ZSM4) -=$$i ; done
	$(ZXCC) $(DRLINK) -"tedvt=termdef,main,fileio,scrn,cmds,cpmio"


clean:
	$(RM) *.rel *.sym *.prn *.map *.crf core *~ *.\$$\$$\$$ termsel.inc
