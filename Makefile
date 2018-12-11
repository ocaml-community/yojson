.PHONY: all
all:
	@dune build @install @DEFAULT

.PHONY: test
test:
	@dune runtest --force

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
