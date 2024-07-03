# ZCN man makefile
#
# A POSIX split command is required, but that shouldn't be a problem.
#
# Edit CC/CFLAGS if necessary. -O3 is used here as zx0 is more
# CPU-hungry than you might expect.

CC=gcc
CFLAGS=-O3

AWK=awk

all: man ../doc/manindex.txt

man: ../bin/man.com ../bin/manpages.dat

# this is just a more convenient copy of index.man for doc dir
../doc/manindex.txt: pages/index.man
	cp pages/index.man ../doc/manindex.txt

../bin/man.com: man.z view.z dzx0_standard.asm
	zmac man.z
	mv man.bin ../bin/man.com

# this stops it always doing a pointless rebuild after "make clean".
.SECONDARY: laransi zx0

laransi: laransi.c
	$(CC) $(CFLAGS) -o laransi laransi.c

# I use a version with it all smushed into one file because reasons.
zx0: zx0full.c
	$(CC) $(CFLAGS) -o zx0 zx0full.c


# This makes the manpages.dat data file.
#
# The basic idea here:
#
# - make LBR containing all the man pages
# - split it into 16k chunks
# - use zx0 to compress each one
# - make a 128-byte header with offset/length in records for those
# - add on each compressed chunk, padded to nearest 128-byte record
#
# This isn't optimal, as it could waste about 1k or so. But it makes
# the ZCN side easier to deal with.
#
# Using awk for the hex lengths is weird, but the obvious choice
# is dc - which these days would be more likely to need installing.
# (Mind you, I use dc elsewhere when building ZCN. Oh well.)
#
# All the zx0 commands (perhaps seven) are run at once, so this will
# definitely eat some CPU for a bit. It runs them all backgrounded (to
# take advantage of multiple cores), with one left doing a progress
# bar to give an idea of how long it'll take.
#
# The input LBR must be <=256k due to inefficiency in the 128-byte
# header, but that's so far off that it isn't even checked for - more
# than double the current size. Also, man assumes the LBR has a
# 256-entry directory (again, more than double what's used).
#
../bin/manpages.dat: laransi zx0 pages/*.man
	$(RM) manpages.lbr x?? x??.zx0 x??.pad
	cd pages;echo 256 |../laransi u ../manpages.lbr *.man >/dev/null
	split -b 16k manpages.lbr
	@echo 'Building zx0 files, this may take a while...'
	@echo '(Only one progress bar is shown, but several processes will run)'
	./zx0 xaa & for i in xa[b-z]; do ./zx0 $$i >/dev/null & done; wait
	for i in xa?; do \
	  cp $$i.zx0 $$i.pad; \
	  wc -c <$$i.zx0 |\
	    $(AWK) '{f=$$0%128;if(f>0){for(;f<128;f++)printf("x")}}' \
	    >>$$i.pad; \
	done
	(for i in xa?.pad; do wc -c <$$i; done) |\
	  $(AWK) '{l=int($$0/128);printf("%04X%04X",t,l);t+=l}' >xza
	cp xza xza.pad
	wc -c <xza |\
	    $(AWK) '{f=$$0%128;if(f>0){for(;f<128;f++)printf("0")}}' >>xza.pad
	cat xza.pad xa?.pad >../bin/manpages.dat

clean:
	$(RM) *~ pages/*~ *.lst laransi zx0 manpages.lbr x?? x??.zx0 x??.pad
