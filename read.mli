(* $Id$ *)

val read_json : Buffer.t -> Lexing.lexbuf -> json

val finish_string : Buffer.t -> Lexing.lexbuf -> string
val finish_escaped_char : Buffer.t -> Lexing.lexbuf -> unit
val finish_variant : Buffer.t -> Lexing.lexbuf -> json option
val close_variant : Lexing.lexbuf -> unit
val finish_comment : Lexing.lexbuf -> unit

val read_space : Lexing.lexbuf -> unit
val read_null : Lexing.lexbuf -> unit
val read_bool : Lexing.lexbuf -> bool
val read_int : Lexing.lexbuf -> int
val read_number : Lexing.lexbuf -> [> `Float of float ]
val read_string : Buffer.t -> Lexing.lexbuf -> string
val read_ident : Buffer.t -> Lexing.lexbuf -> string

val read_sequence :
  ('a -> Lexing.lexbuf -> 'a) -> 'a -> Lexing.lexbuf -> 'a
val read_list : (Lexing.lexbuf -> 'a) -> Lexing.lexbuf -> 'a list
val read_list_rev : (Lexing.lexbuf -> 'a) -> Lexing.lexbuf -> 'a list
val read_array_sep : Lexing.lexbuf -> unit
val read_array : (Lexing.lexbuf -> 'a) -> Lexing.lexbuf -> 'a array

val read_tuple :
  (int -> 'a -> Lexing.lexbuf -> 'a) -> 'a -> Lexing.lexbuf -> 'a
val read_tuple_sep : Lexing.lexbuf -> unit

val read_fields :
  ('a -> string -> Lexing.lexbuf -> 'a) ->
  'a -> Buffer.t -> Lexing.lexbuf -> 'a
val read_object_sep : Lexing.lexbuf -> unit
val read_colon : Lexing.lexbuf -> unit
