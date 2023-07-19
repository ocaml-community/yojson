(**
   Ints, floats and strings literals are systematically preserved using
   [`Intlit], [`Floatlit] and [`Stringlit].
   This module also supports the specific syntax for variants and tuples
   supported by {!Yojson.Safe}.
*)

#define INTLIT
#define FLOATLIT
#define STRINGLIT
#define TUPLE
#define VARIANT

#include "type.ml"

#include "monomorphic.mli"

#include "write.mli"

#include "write2.mli"

#include "read.mli"

(** This module provides combinators for extracting fields from JSON values. *)
module Util : sig
  #include "util.mli"
end

#undef INTLIT
#undef FLOATLIT
#undef STRINGLIT
#undef TUPLE
#undef VARIANT
