# makefile for zcn docs

all: index.txt

index.txt: zcn.txt
	printf 'A simple index of zcn.txt sections:\n\n' >index.txt
	grep '^\*' <zcn.txt >>index.txt

clean:
	$(RM) *~
