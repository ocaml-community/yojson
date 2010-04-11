(* $Id$ *)

type json =
    [
    | `Null
    | `Bool of bool
#ifdef INT
    | `Int of int
#endif
#ifdef INTLIT
    | `Intlit of string
        (* Original integer literal *)
#endif
#ifdef FLOAT
    | `Float of float
#endif
#ifdef FLOATLIT
    | `Floatlit of string
        (* Original decimal number literal *)
#endif
#ifdef STRING
    | `String of string
#endif
#ifdef STRINGLIT
    | `Stringlit of string
        (* Original string literal (including quotes) *)
#endif
    | `Assoc of (string * json) list
    | `List of json list
#ifdef TUPLE
    | `Tuple of json list
        (* Tuple (extension of JSON) *)
#endif
#ifdef VARIANT
    | `Variant of (string * json option)
        (* Variant (extension of JSON) *)
#endif
    ]
