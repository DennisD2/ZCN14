# makefile for ZCN zselx

all: ../bin/zselx.com

SRC=	zselx.z \
	../zcnlib/conio.z ../zcnlib/string.z \
	../zcnlib/maths.z ../zcnlib/qsort.z

../bin/zselx.com: $(SRC)
	zmac zselx.z
	mv zselx.bin ../bin/zselx.com

clean:
	$(RM) *~ *.lst *.bin
