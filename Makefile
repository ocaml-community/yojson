# $Id$

VERSION = 1.0.2

FLAGS = -dtypes
PACKS = easy-format,biniou

.PHONY: default all opt install doc
default: META all opt
all: yojson.cmo
opt: yojson.cmx ydump

ifndef PREFIX
  PREFIX = $(shell dirname $$(dirname $$(which ocamlfind)))
  export PREFIX
endif

ifndef BINDIR
  BINDIR = $(PREFIX)/bin
  export BINDIR
endif

META: META.in Makefile
	sed -e 's:@@VERSION@@:$(VERSION):' META.in > META

install: META
	test ! -f ydump || cp ydump $(BINDIR)/
	test ! -f ydump.exe || cp ydump.exe $(BINDIR)/
	ocamlfind install yojson META \
          $$(ls yojson.mli yojson.cmi yojson.cmo yojson.cmx yojson.o)

uninstall:
	test ! -f $(BINDIR)/ydump || rm $(BINDIR)/ydump
	test ! -f $(BINDIR)/ydump.exe || rm $(BINDIR)/ydump.exe 
	ocamlfind remove yojson

read.ml: read.mll
	ocamllex read.mll

yojson.mli: yojson.mli.cppo \
            common.mli type.ml safe.mli write.mli pretty.mli write2.mli \
            read.mli biniou.mli
	cppo -n yojson.mli.cppo -o yojson.mli

yojson.ml: yojson.ml.cppo \
           common.ml type.ml safe.ml write.ml pretty.ml write2.ml read.ml \
           biniou.ml
	cppo yojson.ml.cppo -o yojson.ml

yojson.cmi: yojson.mli
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson.mli

yojson.cmo: yojson.cmi yojson.ml
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson.ml

yojson.cmx: yojson.cmi yojson.ml
	ocamlfind ocamlopt -c $(FLAGS) -package $(PACKS) yojson.ml

ydump: yojson.cmx ydump.ml
	ocamlfind ocamlopt -o ydump -package $(PACKS) -linkpkg \
		yojson.cmx ydump.ml

doc: doc/index.html
doc/index.html: yojson.mli
	mkdir -p doc
	ocamlfind ocamldoc -d doc -html -package biniou yojson.mli

bench: bench.ml yojson.cmx META
	ocamlfind ocamlopt -o bench \
		-package unix,yojson,json-wheel -linkpkg bench.ml

.PHONY: clean

clean:
	rm -f *.o *.a *.cm* *~ *.annot ydump ydump.exe \
		read.ml yojson.mli yojson.ml META
	rm -rf doc

SUBDIRS = 
SVNURL = svn://scm.ocamlcore.org/svn/yojson/trunk/yojson

.PHONY: archive
archive:
	@echo "Making archive for version $(VERSION)"
	@if [ -z "$$WWW" ]; then \
		echo '*** Environment variable WWW is undefined ***' >&2; \
		exit 1; \
	fi
	@if [ -n "$$(svn status -q)" ]; then \
		echo "*** There are uncommitted changes, aborting. ***" >&2; \
		exit 1; \
	fi
	$(MAKE) && ./ydump -help > $$WWW/ydump-help.txt
	mkdir -p $$WWW/yojson-doc
	$(MAKE) doc && cp doc/* $$WWW/yojson-doc/
	rm -rf /tmp/yojson /tmp/yojson-$(VERSION) && \
		cd /tmp && \
		svn co "$(SVNURL)" && \
		for x in "." $(SUBDIRS); do \
			rm -rf /tmp/yojson/$$x/.svn; \
		done && \
		cd /tmp && cp -r yojson yojson-$(VERSION) && \
		tar czf yojson.tar.gz yojson && \
		tar cjf yojson.tar.bz2 yojson && \
		tar czf yojson-$(VERSION).tar.gz yojson-$(VERSION) && \
		tar cjf yojson-$(VERSION).tar.bz2 yojson-$(VERSION)
	mv /tmp/yojson.tar.gz /tmp/yojson.tar.bz2 ../releases
	mv /tmp/yojson-$(VERSION).tar.gz \
		/tmp/yojson-$(VERSION).tar.bz2 ../releases
	cp ../releases/yojson.tar.gz $$WWW/
	cp ../releases/yojson.tar.bz2 $$WWW/
	cp ../releases/yojson-$(VERSION).tar.gz $$WWW/
	cp ../releases/yojson-$(VERSION).tar.bz2 $$WWW/
	cd ../releases && \
		svn add yojson.tar.gz yojson.tar.bz2 \
			yojson-$(VERSION).tar.gz yojson-$(VERSION).tar.bz2 && \
		svn commit -m "yojson version $(VERSION)"
	cp LICENSE $$WWW/yojson-license.txt
	cp Changes $$WWW/yojson-changes.txt
	echo 'let yojson_version = "$(VERSION)"' \
		> $$WWW/yojson-version.ml
