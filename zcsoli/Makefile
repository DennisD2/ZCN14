# zcsoli - Solitaire/Patience/Klondike card game for CP/M.
# Copyright (C) 2020 Russell Marks. See zcsoli.z for licence.
#
# Makefile

# Tweaked makefile for ZCN -rjm 2022-08-05

# zmac should be zmac 1.3.

all: zcsoli

zcsoli: ../bin/zcsoli.com

../bin/zcsoli.com: zcsoli.z
	zmac zcsoli.z
	mv zcsoli.bin ../bin/zcsoli.com

clean:
	$(RM) *~ *.bin *.lst tmp.z

spotless: clean
	$(RM) ../bin/zcsoli.com
