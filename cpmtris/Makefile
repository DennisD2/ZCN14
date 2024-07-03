# makefile for cpmtris
#
# Separate copies of zcnlib's rand.z and conio.z are used to keep this
# "standalone"... but you'd still need to delete "../bin/" for that.

all: ../bin/cpmtris.com

SRC=cpmtris.z rand.z conio.z

../bin/cpmtris.com: $(SRC)
	zmac cpmtris.z
	mv cpmtris.bin ../bin/cpmtris.com

clean:
	$(RM) *~ *.lst *.bin
