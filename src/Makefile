# ZCN `kernel' makefile

all: zcn

# main.z and eof.z must stay first and last, respectively

ZMAC=zmac

zcn: ../bin/zcn.bin ../bin/zcn150.bin ../bin/zcn200.bin

SRCFILES=main.z start.z \
	init.z inthndl.z bdos.z bios.z zcnfunc.z ccp.z \
	misc.z card.z cardboot.z internal.z \
	powrhndl.z keyread.z serial.z term.z \
	eof.z

# the other files in SRCFILES are included from nc100.z via main.z;
# asmver.z is included from internal.z.
# boot.z is assembled separately.

# stops gratuitous rebuilds
.SECONDARY: 4x6font.bin

4x6font.bin: 4x6font.z
	$(ZMAC) 4x6font.z

../bin/zcn.bin: boot.z 4x6font.bin nc100.z $(SRCFILES)
	$(RM) asmver.z
	head -1 start.z | \
	  sed -e 's/^;ZCN /defb '\'ZCN\ / -e 's/ -.*/'\'/ >asmver.z
	echo ';build date/time' >>asmver.z
	date "+defb ' (%Y-%m-%d %H:%M)'" >>asmver.z
	$(ZMAC) nc100.z
	$(ZMAC) boot.z
	cat boot.bin nc100.bin 4x6font.bin >../bin/zcn.bin
	ls -l ../bin/zcn.bin
	@printf 'Free bytes left below E600h for NC100: '
	@echo 16 i E600 `grep 'zcn_eof:$$' nc100.lst|cut -f 2` - f | dc


../bin/zcn150.bin: boot.z 4x6font.bin nc150.z $(SRCFILES)
	$(RM) asmver.z
	head -1 start.z | \
	  sed -e 's/^;ZCN /defb '\'ZCN150\ / -e 's/ -.*/'\'/ >asmver.z
	echo ';build date/time' >>asmver.z
	date "+defb ' (%Y-%m-%d %H:%M)'" >>asmver.z
	$(ZMAC) nc150.z
	$(ZMAC) boot.z
	cat boot.bin nc150.bin 4x6font.bin >../bin/zcn150.bin
	ls -l ../bin/zcn150.bin
	@printf 'Free bytes left below E600h for NC150: '
	@echo 16 i E600 `grep 'zcn_eof:$$' nc150.lst|cut -f 2` - f | dc


../bin/zcn200.bin: boot.z 4x6font.bin nc200.z $(SRCFILES)
	$(RM) asmver.z
	head -1 start.z | \
	  sed -e 's/^;ZCN /defb '\'ZCN200\ / -e 's/ -.*/'\'/ >asmver.z
	echo ';build date/time' >>asmver.z
	date "+defb ' (%Y-%m-%d %H:%M)'" >>asmver.z
	$(ZMAC) nc200.z
	$(ZMAC) boot.z
	cat boot.bin nc200.bin 4x6font.bin >../bin/zcn200.bin
	ls -l ../bin/zcn200.bin
	@printf 'Free bytes left below E600h for NC200: '
	@echo 16 i E600 `grep 'zcn_eof:$$' nc200.lst|cut -f 2` - f | dc

clean:
	$(RM) *~ *.lst *.bin asmver.z

spotless: clean
	$(RM) ../bin/zcn.bin ../bin/zcn150.bin ../bin/zcn200.bin
