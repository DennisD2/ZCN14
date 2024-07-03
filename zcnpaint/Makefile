# makefile for zcnpaint

all: ../bin/extra/zcnpaint.com

SRC=zcnpaint.z iconpan.z defpats.z \
	../zcnlib/maths.z \
	../zcnlib/stdio.z ../zcnlib/conio.z \
	../zcnlib/sqrt.z \
	../zcnlib/graph.z ../zcnlib/graph2.z \
	../zcnlib/mouse.z

../bin/extra/zcnpaint.com: $(SRC)
	cat $(SRC) >out.z
	zmac out.z
	mv out.bin ../bin/extra/zcnpaint.com

clean:
	$(RM) *~ *.lst *.bin out.z
