# top-level ZCN makefile


# for `make zip' - this is the version number without the dot (to keep
# the zip's traditional 8.3-friendly filename), e.g. `1.2' becomes `12'.
VERS=14

ZIPFILE=../zcn$(VERS).zip


# the utils one does a whole bunch, much more than it should frankly -
# so it really needs to be last here
DIRS=bin cpmtris doc man src support \
	zcnlib zcnpaint zcsoli zselx \
	images \
	utils


all: zcn

# for any BSD types :-)
World: world
world: zcn

zcn:
	for i in $(DIRS); do $(MAKE) -C $$i; done

install:
	@echo 'See doc/zcn.txt for how to install ZCN.'



clean:
	for i in $(DIRS); do $(MAKE) -C $$i clean; done
	$(RM) *~


dist: zip

zip: $(ZIPFILE)

# Note that the make clean deletes temp files, `*~', etc. rather
# than generated binaries.
#
$(ZIPFILE): zcn clean
	$(RM) $(ZIPFILE)
	chmod -R a+r .
	zip $(ZIPFILE) `find . -type f -print|sed 's,./,,'|sort`
	ls -l $(ZIPFILE)
