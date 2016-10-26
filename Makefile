include $(shell ocamlc -where)/Makefile.config

VERSION = 1.3.3

FLAGS = -bin-annot -dtypes -g
CMO = yojson.cmo yojson_biniou.cmo
CMX = yojson.cmx yojson_biniou.cmx
ifeq ($(NATDYNLINK),true)
CMXS = yojson.cmxs yojson_biniou.cmxs
endif
PACKS = easy-format,biniou

.PHONY: default all opt install uninstall install-lib uninstall-lib \
        reinstall doc install-doc
default: META all opt
all: $(CMO)
opt: $(CMX) $(CMXS) ydump$(EXE)

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

install: META install-lib
	test ! -f ydump$(EXE) || cp ydump $(BINDIR)/

install-lib:
	ocamlfind install yojson META \
	  $(wildcard *.cmt) $(wildcard *.cmti) $(wildcard *.mli) \
	  $(wildcard *.cmi) $(wildcard *$(EXT_LIB)) $(wildcard *.cmo) \
	  $(wildcard *$(EXT_OBJ)) $(wildcard *.cmx) $(wildcard *.cmxs)

uninstall: uninstall-lib
	test ! -f $(BINDIR)/ydump$(EXE) || rm $(BINDIR)/ydump$(EXE)

uninstall-lib:
	ocamlfind remove yojson

reinstall:
	$(MAKE) BINDIR=$(BINDIR) uninstall
	$(MAKE) BINDIR=$(BINDIR) install

read.ml: read.mll
	ocamllex read.mll

yojson.mli: yojson.mli.cppo \
            common.mli type.ml safe.mli write.mli pretty.mli write2.mli \
            read.mli util.mli
	cppo -n yojson.mli.cppo -o yojson.mli

yojson.ml: yojson.ml.cppo \
           common.ml type.ml safe.ml write.ml pretty.ml write2.ml \
           read.ml util.ml
	cppo -D "VERSION $(VERSION)" yojson.ml.cppo -o yojson.ml

yojson.cmi: yojson.mli
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson.mli

yojson.cmo: yojson.cmi yojson.ml
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson.ml

yojson.cmx: yojson.cmi yojson.ml
	ocamlfind ocamlopt -c $(FLAGS) -package $(PACKS) yojson.ml

yojson.cmxs: yojson.cmx
	ocamlfind ocamlopt -shared -linkall -I . -o yojson.cmxs yojson.cmx

yojson_biniou.cmi: yojson_biniou.mli
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson_biniou.mli

yojson_biniou.cmo: yojson_biniou.cmi yojson_biniou.ml
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson_biniou.ml

yojson_biniou.cmx: yojson_biniou.cmi yojson_biniou.ml
	ocamlfind ocamlopt -c $(FLAGS) -package $(PACKS) yojson_biniou.ml

yojson_biniou.cmxs: yojson_biniou.cmx
	ocamlfind ocamlopt -shared -linkall -I . -o yojson_biniou.cmxs \
		yojson_biniou.cmx

ydump$(EXE): yojson.cmx yojson_biniou.cmx ydump.ml
	ocamlfind ocamlopt -o ydump$(EXE) $(FLAGS) -package $(PACKS) -linkpkg \
		$(CMX) ydump.ml

doc: doc/index.html
doc/index.html: yojson.mli yojson_biniou.mli
	mkdir -p doc
	ocamlfind ocamldoc -d doc -html -package biniou \
		yojson.mli yojson_biniou.mli

install-doc:
	cp doc/* $$WWW/yojson-doc/

bench: bench.ml yojson.cmx META
	ocamlfind ocamlopt -o bench \
		-package unix,yojson,json-wheel -linkpkg bench.ml

.PHONY: clean

clean:
	rm -f *.o *.a *.cm* *~ *.annot ydump$(EXE) \
		read.ml yojson.mli yojson.ml META
	rm -rf doc
	cd examples; $(MAKE) clean
