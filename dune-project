(lang dune 2.7)
(name yojson)

(generate_opam_files true)
(source (github ocaml-community/yojson))
(license BSD-3-Clause)

(maintainers "paul-elliot@tarides.com" "nathan@tarides.com" "marek@tarides.com")
(authors "Martin Jambon")
(documentation "https://ocaml-community.github.io/yojson")

(package
  (name yojson)
  (synopsis "Yojson is an optimized parsing and printing library for the JSON format")
  (description "Yojson is an optimized parsing and printing library for the JSON format.

ydump is a pretty-printing command-line program provided with the
yojson package.")
  (depends
    (ocaml (>= 4.02.3))
    (cppo :build)
    (alcotest (and :with-test (>= 0.8.5)))
    (seq (>= 0.2.2))))

(package
  (name yojson-bench)
  (synopsis "Run Yojson benchmarks")
  (description "Yojson benchmarks require `Core_bench` which is not a dependency of Yojson,
because it is not part of the regular installation/testing flow. This is solely
meant for developers that are worried about performance changes in Yojson.")
  (depends
    (ocaml (>= 4.08))
    (yojson (= :version))
    (core_bench (>= v0.15.0))
    (core (>= v0.14.0))
    (core_unix (>= v0.14.0))
    (sexplib (>= v0.9.0))))
