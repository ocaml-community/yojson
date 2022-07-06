.PHONY: all
all:
	@dune build @install @examples

.PHONY: run-examples
run-examples:
	dune exec examples/filtering.exe < examples/filtering.json

.PHONY: install
install:
	@dune install

.PHONY: uninstall
uninstall:
	@dune uninstall

.PHONY: bench
bench:
	@ dune build bench/bench.exe
	@ dune build @bench-generic-sexp --force 2>&1 | dune exec bench/conversions.exe -- generic
	@ dune build @bench-buffer-sexp --force 2>&1 | dune exec bench/conversions.exe -- buffer

.PHONY: bench-local
bench-local:
	@dune build @bench --force

.PHONY: clean
clean:
	@dune clean

.PHONY: test
test:
	@dune runtest --force

