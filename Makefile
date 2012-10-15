VERSION = 1.1.7

ifeq "$(shell ocamlc -config |grep os_type)" "os_type: Win32"
EXE=.exe
else
EXE=
endif


FLAGS = -dtypes -g
CMO = yojson.cmo yojson_biniou.cmo
CMX = yojson.cmx yojson_biniou.cmx
CMXS = yojson.cmxs
PACKS = easy-format,biniou

.PHONY: default all opt install uninstall reinstall doc install-doc
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

install: META
	test ! -f ydump || cp ydump $(BINDIR)/
	test ! -f ydump.exe || cp ydump.exe $(BINDIR)/
	ocamlfind install yojson META \
          $$(ls yojson.mli yojson_biniou.mli \
		yojson.cmi yojson_biniou.cmi \
		$(CMO) $(CMX) $(CMXS) \
		yojson.o yojson_biniou.o)

uninstall:
	test ! -f $(BINDIR)/ydump || rm $(BINDIR)/ydump
	test ! -f $(BINDIR)/ydump.exe || rm $(BINDIR)/ydump.exe 
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
	ocamlopt -shared -linkall -I . -o yojson.cmxs yojson.cmx

yojson_biniou.cmi: yojson_biniou.mli
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson_biniou.mli

yojson_biniou.cmo: yojson_biniou.cmi yojson_biniou.ml
	ocamlfind ocamlc -c $(FLAGS) -package $(PACKS) yojson_biniou.ml

yojson_biniou.cmx: yojson_biniou.cmi yojson_biniou.ml
	ocamlfind ocamlopt -c $(FLAGS) -package $(PACKS) yojson_biniou.ml

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
	rm -f *.o *.a *.cm* *~ *.annot ydump ydump.exe \
		read.ml yojson.mli yojson.ml META
	rm -rf doc
	cd examples; $(MAKE) clean
