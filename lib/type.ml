(** {3 Type of the JSON tree} *)

#ifdef POSITION
type position = {
  file_name : string option;
  start_line : int;
  start_column : int;
(*
  end_line : int;
  end_column : int;
*)
}
#endif

type json =
#ifdef POSITION
  position *
#endif
    [
    | `Null
    | `Bool of bool
#ifdef INT
    | `Int of int
#endif
#ifdef INTLIT
    | `Intlit of string
#endif
#ifdef FLOAT
    | `Float of float
#endif
#ifdef FLOATLIT
    | `Floatlit of string
#endif
#ifdef STRING
    | `String of string
#endif
#ifdef STRINGLIT
    | `Stringlit of string
#endif
    | `Assoc of (string * json) list
    | `List of json list
#ifdef TUPLE
    | `Tuple of json list
#endif
#ifdef VARIANT
    | `Variant of (string * json option)
#endif
    ]
(**
All possible cases defined in Yojson:
- `Null: JSON null
- `Bool of bool: JSON boolean
- `Int of int: JSON number without decimal point or exponent.
- `Intlit of string: JSON number without decimal point or exponent,
	    preserved as a string.
- `Float of float: JSON number, Infinity, -Infinity or NaN.
- `Floatlit of string: JSON number, Infinity, -Infinity or NaN,
	    preserved as a string.
- `String of string: JSON string. Bytes in the range 128-255 are preserved
	    as-is without encoding validation for both reading
	    and writing.
- `Stringlit of string: JSON string literal including the double quotes.
- `Assoc of (string * json) list: JSON object.
- `List of json list: JSON array.
- `Tuple of json list: Tuple (non-standard extension of JSON).
	    Syntax: [("abc", 123)].
- `Variant of (string * json option): Variant (non-standard extension of JSON).
	    Syntax: [<"Foo">] or [<"Bar":123>].
*)
(*
  Note to adventurers: ocamldoc does not support inline comments
  on each polymorphic variant, and cppo doesn't allow to concatenate
  comments, so it would be complicated to document only the
  cases that are preserved by cppo in the type definition.
*)

#ifdef POSITION
  let rec forget_positions ((_, x) : json) =
    match x with
    | `Null -> `Null
    | `Bool b -> `Bool b
  #ifdef INT
    | `Int i -> `Int i
  #endif
  #ifdef INTLIT
    | `Intlit s -> `Intlit s
  #endif
  #ifdef FLOAT
    | `Float r -> `Float r
  #endif
  #ifdef FLOATLIT
    | `Floatlit s -> `Floatlit s
  #endif
  #ifdef STRING
    | `String s -> `String s
  #endif
  #ifdef STRINGLIT
    | `Stringlit s -> `Stringlit s
  #endif
    | `Assoc assoc -> `Assoc (assoc |> List.map (fun (k, v) -> (k, forget_positions v)))
    | `List js -> `List (js |> List.map forget_positions)
  #ifdef TUPLE
    | `Tuple js -> `Tuple (js |> List.map forget_positions)
  #endif
  #ifdef VARIANT
    | `Variant (s, jopt) ->
        begin
          match jopt with
          | None -> `Variant (s, None)
          | Some(j) -> `Variant (s, Some(forget_positions j))
        end
  #endif
#endif
