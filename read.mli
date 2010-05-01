(* $Id$ *)

val finish_string : Buffer.t -> Lexing.lexbuf -> string
val finish_escaped_char : Buffer.t -> Lexing.lexbuf -> unit
val finish_variant : Buffer.t -> Lexing.lexbuf -> json option
val close_variant : Lexing.lexbuf -> unit
val finish_comment : Lexing.lexbuf -> unit

val read_space : Lexing.lexbuf -> unit
val read_eof : Lexing.lexbuf -> bool
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
val read_array_end : Lexing.lexbuf -> unit
val read_array_sep : Lexing.lexbuf -> unit
val read_array : (Lexing.lexbuf -> 'a) -> Lexing.lexbuf -> 'a array

val read_tuple :
  (int -> 'a -> Lexing.lexbuf -> 'a) -> 'a -> Lexing.lexbuf -> 'a
val read_tuple_end : Lexing.lexbuf -> unit
val read_tuple_sep : Lexing.lexbuf -> unit

val read_fields :
  ('a -> string -> Lexing.lexbuf -> 'a) ->
  'a -> Buffer.t -> Lexing.lexbuf -> 'a
val read_object_end : Lexing.lexbuf -> unit
val read_object_sep : Lexing.lexbuf -> unit
val read_colon : Lexing.lexbuf -> unit


val read_json : Buffer.t -> Lexing.lexbuf -> json

val from_lexbuf : ?buf:Buffer.t -> ?stream:bool -> Lexing.lexbuf -> json

val from_string : ?buf:Buffer.t -> string -> json
val from_channel : ?buf:Buffer.t -> in_channel -> json
val from_file : ?buf:Buffer.t -> string -> json


type json2 = [ `Json of json | `Exn of exn ]

val stream_from_lexbuf :
  ?buf:Buffer.t -> ?fin:(unit -> unit) -> Lexing.lexbuf -> json Stream.t
val stream2_from_lexbuf :
  ?buf:Buffer.t -> ?fin:(unit -> unit) -> Lexing.lexbuf -> json2 Stream.t

val stream_from_string : ?buf:Buffer.t -> string -> json Stream.t
val stream2_from_string : ?buf:Buffer.t -> string -> json2 Stream.t

val stream_from_channel :
  ?buf:Buffer.t -> ?fin:(unit -> unit) -> in_channel -> json Stream.t
val stream2_from_channel :
  ?buf:Buffer.t -> ?fin:(unit -> unit) -> in_channel -> json2 Stream.t

val stream_from_file : ?buf:Buffer.t -> string -> json Stream.t
val stream2_from_file : ?buf:Buffer.t -> string -> json2 Stream.t
