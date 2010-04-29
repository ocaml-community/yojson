FLAGS = -dtypes
PACKS = easy-format,biniou

.PHONY: default all opt
default: all opt
all: yojson.cmo
opt: yojson.cmx ydump

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

.PHONY: clean

clean:
	rm -f *.o *.a *.cm* *~ *.annot ydump ydump.exe \
		read.ml yojson.mli yojson.ml
