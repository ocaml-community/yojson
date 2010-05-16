# $Id$

VERSION = 0.8.0

FLAGS = -dtypes
PACKS = easy-format,biniou

.PHONY: default all opt install
default: all opt
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
            common.mli type.ml write.mli pretty.mli write2.mli read.mli
	cppo -n yojson.mli.cppo -o yojson.mli

yojson.ml: yojson.ml.cppo \
           common.ml type.ml write.ml pretty.ml write2.ml read.ml
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

bench: bench.ml yojson.cmx META
	ocamlfind ocamlopt -o bench \
		-package unix,yojson,json-wheel -linkpkg bench.ml

.PHONY: clean

clean:
	rm -f *.o *.a *.cm* *~ *.annot ydump ydump.exe \
		read.ml yojson.mli yojson.ml META
