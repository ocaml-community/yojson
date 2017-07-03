all:
	@jbuilder build @install @DEFAULT

test:
	@jbuilder runtest

check: test

bench:
	@jbuilder build bench/bench.exe

.PHONY: clean bench all bench test check

clean:
	jbuilder clean
