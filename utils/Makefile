# ZCN utils makefile

SPELL_SRC=spell.z \
	../zcnlib/stdio.z ../zcnlib/conio.z \
	../zcnlib/string.z ../zcnlib/ctype.z \
	../zcnlib/maths.z

EXPR_SRC=expr.z \
	../zcnlib/int32.z \
	../zcnlib/string.z ../zcnlib/ctype.z


all: utils games imgbuild

utils: \
	../bin/bbcbas.com \
	../bin/bbcmin.com \
	../bin/bigrun.com \
	../bin/bigv.com \
	../bin/bmp.com \
	../bin/cal.com \
	../bin/codes.com \
	../bin/dclock.com \
	../bin/defrag.com \
	../bin/dmp2txt.com \
	../bin/du.com \
	../bin/expr.com \
	../bin/head.com \
	../bin/keyb.com \
	../bin/keyb.uue \
	../bin/ls.com \
	../bin/lfconv.com \
	../bin/ncspeed.com \
	../bin/nctest.com \
	../bin/optdir.com \
	../bin/extra/play4b.com \
	../bin/rrinit.bin \
	../bin/rrxfer.com \
	../bin/ruler.com \
	../bin/runrom.com \
	../bin/semi.com \
	../bin/slide.com \
	../bin/spell.com \
	../bin/spellwd.com \
	../bin/extra/stat.com \
	../bin/submit.com \
	../bin/time.com \
	../bin/timeset.com \
	../bin/zdbe.com \
	../bin/zrx.com \
	../bin/zrx.uue \
	../bin/zx0com.bin

games: \
	../bin/invaders.com

../bin/rrinit.bin: rrinit.z
	zmac rrinit.z
	mv rrinit.bin ../bin

../bin/bbcbas.com: bbcbas.z bbc_io.z bbc_cat.z
	zmac bbcbas.z
	@printf 'Free bytes in block1: '
	@echo 3072 16i `grep block1_siz.equ bbcbas.lst|cut -f 2` -f|dc|tee tmp.lst
	@if [ `cat tmp.lst` -lt 0 ]; then echo '*** failed'; exit 1; fi
	@printf 'Free bytes in block2: '
	@echo 1024 16i `grep block2_siz.equ bbcbas.lst|cut -f 2` -f|dc|tee tmp.lst
	@if [ `cat tmp.lst` -lt 0 ]; then echo '*** failed'; exit 1; fi
	mv bbcbas.bin ../bin/bbcbas.com

../bin/bbcmin.com: bbcmin.z bbc_io.z
	zmac bbcmin.z
	@printf 'Free bytes in block1: '
	@echo 3072 16i `grep block1_siz.equ bbcmin.lst|cut -f 2` -f|dc|tee tmp.lst
	@if [ `cat tmp.lst` -lt 0 ]; then echo '*** failed'; exit 1; fi
	mv bbcmin.bin ../bin/bbcmin.com

../bin/bigrun.com: brsetup.z brpatch.z
	zmac brsetup.z
	zmac brpatch.z
	cat brsetup.bin brpatch.bin >../bin/bigrun.com

../bin/lfconv.com: lfconv.z ../zcnlib/stdio.z
	sed -e '/^dmabuf:/d' -e 's/^fseek:/if 0/' <../zcnlib/stdio.z >tmpstd.z
	echo endif >>tmpstd.z
	cat lfconv.z tmpstd.z >out.z
	zmac out.z
	$(RM) tmpstd.z
	mv out.bin ../bin/lfconv.com

../bin/spell.com: $(SPELL_SRC)
	cat $(SPELL_SRC) >out.z
	echo eof: >>out.z
	zmac out.z
	mv out.bin ../bin/spell.com

../bin/cal.com: cal.z cal_end.z ../zcnlib/args.z
	sed -e '/^argline:/d' -e '/^argv:/d' <../zcnlib/args.z >tmpargs.z
	cat cal.z tmpargs.z cal_end.z >out.z
	zmac out.z
	$(RM) tmpargs.z
	mv out.bin ../bin/cal.com

../bin/expr.com: $(EXPR_SRC)
	cat $(EXPR_SRC) >out.z
	zmac out.z
	mv out.bin ../bin/expr.com

../bin/slide.com: slide.z slidebmp.mrf
	zmac slide.z
	cat slidebmp.mrf >>slide.bin
	mv slide.bin ../bin/slide.com

../bin/bigv.com: bigv.z bigvfont.z bigvdat.z \
		../zcnlib/stdio.z ../zcnlib/conio.z
	sed '/^dmabuf:/d' <../zcnlib/stdio.z >tmpstd.z
	cat bigv.z tmpstd.z >out.z
	zmac out.z
	$(RM) tmpstd.z
	mv out.bin ../bin/bigv.com

../bin/zx0com.bin: zx0com.z
	zmac zx0com.z
	mv zx0com.bin ../bin

../bin/keyb.uue: ../bin/keyb.com
	uuencode ../bin/keyb.com keyb.com >../bin/keyb.uue

../bin/zrx.uue: ../bin/zrx.com
	uuencode ../bin/zrx.com zrx.com >../bin/zrx.uue


slidebmp.mrf: slidebmp.c
	$(CC) -o slidebmp slidebmp.c -lm
	zmac -o 4x6font.bin ../src/4x6font.z
	./slidebmp
	$(RM) slidebmp 4x6font.bin

bigvdat.z: bdf2z.c
	$(CC) -o bdf2z bdf2z.c
	./bdf2z 1 <helvR10.bdf >bigvdat.z
	$(RM) bdf2z


# The card-image-building is a bit lengthy, so it's mostly separated out.
include imgbuild.mk


clean:
	$(RM) *~ *.lst *.bin out.z tmpargs.z tmp*.card auto.prg
	$(RM) slidebmp bdf2z makecimg optdir-c ramdfix
	$(RM) load4000.* call4000.*


# rules
# the format may make them specific to GNU make
../bin/%.com: %.z
	zmac $(subst ../bin/,,$<)
	mv `basename $< .z`.bin $@
../bin/extra/%.com: %.z
	zmac $(subst ../bin/,,$<)
	mv `basename $< .z`.bin $@
