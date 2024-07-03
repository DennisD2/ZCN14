# ZCN imgbuild makefile section

imgbuild: \
	../images/nc100.card \
	../images/nc150.card \
	../images/nc200.card \
	../images/nc200fd.raw \
	../images/image100.txt \
	../images/image150.txt \
	../images/image200.txt \
	../images/imagefd.txt

# A: drive files suitable for all models
# (Generally uncompressed files are used, but md5cpm's size is a bit
# absurd for the uncompressed version.)
BASE_A=\
	../bin/bbcbas.com \
	../bin/bbcmin.com \
	../bin/bigv.com \
	../bin/bmp.com \
	../bin/cal.com \
	../bin/cpmtris.com \
	../bin/codes.com \
	../bin/defrag.com \
	../bin/dclock.com \
	../bin/du.com \
	../bin/expr.com \
	../bin/head.com \
	../bin/keyb.com \
	../bin/ls.com \
	../bin/lfconv.com \
	../bin/man.com \
	../bin/manpages.dat \
	../bin/optdir.com \
	../bin/rrxfer.com \
	../bin/ruler.com \
	../bin/runrom.com \
	../bin/semi.com \
	../bin/slide.com \
	../bin/spell.com \
	../bin/spellwd.com \
	../bin/submit.com \
	../bin/time.com \
	../bin/timeset.com \
	../bin/zcsoli.com \
	../bin/zdbe.com \
	../bin/zselx.com \
	../support/zx0alt/md5cpm.com \
	../support/pipe/pipe.com \
	../support/qterm.com

# additional A: files for NC100 only
NC100_A=\
	../support/ted/ted.com

# additional A: files for NC150 only
NC150_A=\
	../support/ted/ted.com

# additional A: files for NC200 only
NC200_A=\
	../support/ted/ted200.com


# B: drive files suitable for all models
BASE_B=\
	../bin/ncspeed.com \
	../bin/nctest.com \
	../support/chess/chess.com \
	../support/fish/fish.com \
	../support/lar.com \
	../support/rogue/rogue.com \
	../support/wade/wade.com

# additional B: files for NC100 only
NC100_B=\
	../bin/dmp2txt.com \
	../bin/invaders.com \
	../support/bs/bs.com

# additional B: files for NC150 only
NC150_B=$(NC100_B)

# additional B: files for NC200 only
NC200_B=\
	../support/bs/bs200.com


# C: drive files suitable for all models
# (C: is mostly for the more esoteric or awkward stuff)
BASE_C=\
	../bin/extra/play4b.com \
	../bin/extra/stat.com \
	../bin/zrx.com \
	../support/rogue/roguevt.com \
	../support/samples/arpent.4b \
	../support/ted/tedvt.com

# zcnpaint is dumped on here because it needs a serial mouse,
# or nc100em's hack
NC100_C=\
	../bin/bigrun.com \
	../bin/extra/zcnpaint.com

NC150_C=\
	../bin/extra/zcnpaint.com

NC200_C=


# D: is probably just getting left empty (almost)
# (I mean, I could e.g. put zcn.txt on there, but not uncompressed...)
BASE_D=\
	blank.txt


# Bonus mini A: drive, 48k ramdisk for NC200 floppy boot
# (also includes keyb.com as k.com, see below)
RAMD_A=\
	../bin/bbcmin.com \
	../bin/dclock.com \
	../bin/ls.com \
	../bin/zcsoli.com \
	../support/zx0alt/qterm.com \
	../support/zx0alt/ted200.com


# Don't try to rebuild support files, probably a better way to do this...

../support/bs/bs.com:

../support/chess/chess.com:

../support/fish/fish.com:

../support/lar.com:

../support/pipe/pipe.com:

../support/qterm.com:

../support/rogue/rogue.com:

../support/wade/wade.com:

../support/zx0alt/qterm.com:


# Does need to know how to make these, so this sucks, yay.
# Probably a better build system would make things more sensible,
# but not likely to change it at this point.

../bin/cpmtris.com:
	make -C ../cpmtris

../bin/man.com:
	make -C ../man

../bin/manpages.dat:
	make -C ../man

../bin/zcn.bin:
	make -C ../src

../bin/zcn150.bin:
	make -C ../src

../bin/zcn200.bin:
	make -C ../src

../bin/extra/zcnpaint.com:
	make -C ../zcnpaint

../bin/zcsoli.com:
	make -C ../zcsoli

../bin/zcsol200.com:
	make -C ../zcsoli

../bin/zselx.com:
	make -C ../zselx


# Things needed for booting, and tools for making images

.SECONDARY: makecimg optdir-c ramdfix

makecimg: makecimg.c

optdir-c: optdir-c.c

ramdfix: ramdfix.c


# These are straight-up case-and-paste, alas - the thing to watch for
# is zcn.bin, which a simple nc150/nc200 replacement won't catch.

../images/nc100.card: makecimg optdir-c ../bin/zcn.bin \
	$(BASE_A) $(NC100_A) $(BASE_B) $(NC100_B) \
	$(BASE_C) $(NC100_C) $(BASE_D)
	./makecimg <../bin/zcn.bin >tmp.card
	cpmcp -f zcna tmp.card ../bin/keyb.com 0:k.com
	cpmcp -f zcna tmp.card $(BASE_A) $(NC100_A) 0:
	cpmcp -f zcnb tmp.card $(BASE_B) $(NC100_B) 0:
	cpmcp -f zcnc tmp.card $(BASE_C) $(NC100_C) 0:
	cpmcp -f zcnd tmp.card $(BASE_D)            0:
	for i in zcna zcnb zcnc zcnd; do \
	  echo $$i; cpmls -D -f $$i tmp.card |grep Free; done
	./optdir-c <tmp.card >../images/nc100.card

../images/nc150.card: makecimg optdir-c ../bin/zcn150.bin \
	$(BASE_A) $(NC150_A) $(BASE_B) $(NC150_B) \
	$(BASE_C) $(NC150_C) $(BASE_D)
	./makecimg <../bin/zcn150.bin >tmp.card
	cpmcp -f zcna tmp.card ../bin/keyb.com 0:k.com
	cpmcp -f zcna tmp.card $(BASE_A) $(NC150_A) 0:
	cpmcp -f zcnb tmp.card $(BASE_B) $(NC150_B) 0:
	cpmcp -f zcnc tmp.card $(BASE_C) $(NC150_C) 0:
	cpmcp -f zcnd tmp.card $(BASE_D)            0:
	for i in zcna zcnb zcnc zcnd; do \
	  echo $$i; cpmls -D -f $$i tmp.card |grep Free; done
	./optdir-c <tmp.card >../images/nc150.card

../images/nc200.card: makecimg optdir-c ../bin/zcn200.bin \
	$(BASE_A) $(NC200_A) $(BASE_B) $(NC200_B) \
	$(BASE_C) $(NC200_C) $(BASE_D)
	./makecimg <../bin/zcn200.bin >tmp.card
	cpmcp -f zcna tmp.card ../bin/keyb.com 0:k.com
	cpmcp -f zcna tmp.card $(BASE_A) $(NC200_A) 0:
	cpmcp -f zcnb tmp.card $(BASE_B) $(NC200_B) 0:
	cpmcp -f zcnc tmp.card $(BASE_C) $(NC200_C) 0:
	cpmcp -f zcnd tmp.card $(BASE_D)            0:
	for i in zcna zcnb zcnc zcnd; do \
	  echo $$i; cpmls -D -f $$i tmp.card |grep Free; done
	./optdir-c <tmp.card >../images/nc200.card

# floppy disk image - the drive is made on B:, and extracted once
# we're done.
../images/nc200fd.raw: makecimg optdir-c ../bin/zcn200.bin \
	ramdfix nc2fdimg.z nc2fdshm.z nc2autop.z \
	$(RAMD_A) ../bin/keyb.com
	./makecimg <../bin/zcn200.bin >tmp.card
	./ramdfix tmp.card
	cpmcp -f zcn-build-only-ramd tmp.card ../bin/keyb.com 0:k.com
	cpmcp -f zcn-build-only-ramd tmp.card $(RAMD_A) 0:
	cpmls -D -f zcn-build-only-ramd tmp.card |grep Free
	./optdir-c <tmp.card >tmp2.card
	dd if=tmp2.card bs=1024 skip=256 count=16 of=load4000.45
	dd if=tmp2.card bs=1024 skip=272 count=16 of=load4000.46
	dd if=tmp2.card bs=1024 skip=288 count=16 of=load4000.47
	zmac nc2fdimg.z
	zmac nc2fdshm.z
	zmac nc2autop.z
	mv nc2autop.bin auto.prg
	cp nc2fdimg.bin ../images/nc200fd.raw
	truncate -s 720k ../images/nc200fd.raw
	cat nc2fdshm.bin ../bin/zcn200.bin >load4000.44
	truncate -s 13k load4000.44
	touch call4000.44
	mcopy -v -i ../images/nc200fd.raw auto.prg load4000.* call4000.* ::
	

../images/image100.txt: ../images/nc100.card
	(echo NC100 card image contents; echo; echo; \
	 for i in zcna zcnb zcnc zcnd; do \
	  echo $$i |tr a-d A-D |awk '{print "Drive " substr($$0,4,1) ":\n"}'; \
	  cpmls -D -f $$i ../images/nc100.card; echo; echo; \
	  done) \
	  >../images/image100.txt

../images/image150.txt: ../images/nc150.card
	(echo NC150 card image contents; echo; echo; \
	 for i in zcna zcnb zcnc zcnd; do \
	  echo $$i |tr a-d A-D |awk '{print "Drive " substr($$0,4,1) ":\n"}'; \
	  cpmls -D -f $$i ../images/nc150.card; echo; echo; \
	  done) \
	  >../images/image150.txt

../images/image200.txt: ../images/nc200.card
	(echo NC200 card image contents; echo; echo; \
	 for i in zcna zcnb zcnc zcnd; do \
	  echo $$i |tr a-d A-D |awk '{print "Drive " substr($$0,4,1) ":\n"}'; \
	  cpmls -D -f $$i ../images/nc200.card; echo; echo; \
	  done) \
	  >../images/image200.txt

# This only bothers copying out the first 16k, as that has the dir
# blocks. The awk line fixes the k-free bit, but also condenses
# the multiple spaces into one between per field... oh well, it'll do.
../images/imagefd.txt: ../images/nc200fd.raw
	(echo NC200 boot floppy ramdisk contents; echo; echo; \
	 mcopy -ni ../images/nc200fd.raw ::load4000.45 tmp.card; \
	 cpmls -D -f zcna_nonboot tmp.card; echo; echo) | \
	 awk '/K Free/ {$$5=$$5-208 "K"};{print}' \
	 >../images/imagefd.txt
