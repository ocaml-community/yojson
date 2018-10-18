#! /bin/sh

echo "----- Example 1: filtering -----"
ocamlfind ocamlopt -o filtering filtering.ml -package yojson -linkpkg
./filtering < filtering.json

echo "----- Example 2: filtering_pos -----"
ocamlfind ocamlopt -o filtering_pos filtering_pos.ml -package yojson -linkpkg
./filtering_pos < filtering.json
