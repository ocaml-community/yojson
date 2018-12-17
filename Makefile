.PHONY: all
all:
	@dune build @install @examples

.PHONY: run-examples
run-examples:
	dune exec examples/filtering.exe < examples/filtering.json

.PHONY: check
check: test

.PHONY: install
install:
	@dune install

.PHONY: uninstall
uninstall:
	@dune uninstall

.PHONY: bench
bench:
	@dune build bench/bench.exe

.PHONY: clean
clean:
	@dune clean
