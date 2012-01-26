VERSION = 1.0.3

FLAGS = -dtypes -g
CMO = yojson.cmo yojson_biniou.cmo
CMX = yojson.cmx yojson_biniou.cmx
PACKS = easy-format,biniou

.PHONY: default all opt install doc
default: META all opt
all: $(CMO)
opt: $(CMX) ydump

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
          $$(ls yojson.mli yojson_biniou.mli \
		yojson.cmi yojson_biniou.cmi \
		$(CMO) $(CMX) \
		yojson.o yojson_biniou.o)

uninstall:
	test ! -f $(BINDIR)/ydump || rm $(BINDIR)/ydump
	test ! -f $(BINDIR)/ydump.exe || rm $(BINDIR)/ydump.exe 
	ocamlfind remove yojson

read.ml: read.mll
	ocamllex read.mll

yojson.mli: yojson.mli.cppo \
            common.mli type.ml safe.mli write.mli pretty.mli write2.mli \
            read.mli
	cppo -n yojson.mli.cppo -o yojson.mli

yojson.ml: yojson.ml.cppo \
           common.ml type.ml safe.ml write.ml pretty.ml write2.ml read.ml
	cppo yojson.ml.cppo -o yojson.ml

yojson.cmi: yojson.mli
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson.mli

yojson.cmo: yojson.cmi yojson.ml
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson.ml

yojson.cmx: yojson.cmi yojson.ml
	ocamlfind ocamlopt -c $(FLAGS) -package $(PACKS) yojson.ml

yojson_biniou.cmi: yojson_biniou.mli
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson_biniou.mli

yojson_biniou.cmo: yojson_biniou.cmi yojson_biniou.ml
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson_biniou.ml

yojson_biniou.cmx: yojson_biniou.cmi yojson_biniou.ml
	ocamlfind ocamlopt -c $(FLAGS) -package $(PACKS) yojson_biniou.ml

ydump: yojson.cmx yojson_biniou.cmx ydump.ml
	ocamlfind ocamlopt -o ydump $(FLAGS) -package $(PACKS) -linkpkg \
		$(CMX) ydump.ml

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

GITURL = git@github.com:mjambon/yojson.git

.PHONY: archive
archive:
	@echo "Making archive for version $(VERSION)"
	@if [ -z "$$WWW" ]; then \
		echo '*** Environment variable WWW is undefined. ***' >&2; \
		exit 1; \
	fi
	@if [ -n "$$(git diff)" ]; then \
		echo "*** There are uncommitted changes, aborting. ***" >&2; \
		exit 1; \
	fi
	$(MAKE) && ./ydump -help > $$WWW/ydump-help.txt
	mkdir -p $$WWW/yojson-doc
	$(MAKE) doc && cp doc/* $$WWW/yojson-doc/
	rm -rf /tmp/yojson /tmp/yojson-$(VERSION) && \
		cd /tmp && \
		git clone $(GITURL) && \
		rm -rf /tmp/yojson/$$x/.git && \
		cd /tmp && cp -r yojson yojson-$(VERSION) && \
		tar czf yojson.tar.gz yojson && \
		tar cjf yojson.tar.bz2 yojson && \
		tar czf yojson-$(VERSION).tar.gz yojson-$(VERSION) && \
		tar cjf yojson-$(VERSION).tar.bz2 yojson-$(VERSION)
	mv /tmp/yojson.tar.gz /tmp/yojson.tar.bz2 $$WWW/
	mv /tmp/yojson-$(VERSION).tar.gz \
		/tmp/yojson-$(VERSION).tar.bz2 $$WWW/
	cp LICENSE $$WWW/yojson-license.txt
	cp Changes $$WWW/yojson-changes.txt
	echo 'let yojson_version = "$(VERSION)"' \
		> $$WWW/yojson-version.ml
