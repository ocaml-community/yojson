(* $Id$ *)

type lexer_state

val finish_string : lexer_state -> Lexing.lexbuf -> string
val finish_escaped_char : lexer_state -> Lexing.lexbuf -> unit
val finish_variant : lexer_state -> Lexing.lexbuf -> json option
val close_variant : lexer_state -> Lexing.lexbuf -> unit
val finish_comment : lexer_state -> Lexing.lexbuf -> unit

val read_space : lexer_state -> Lexing.lexbuf -> unit
val read_eof : Lexing.lexbuf -> bool
val read_null : lexer_state -> Lexing.lexbuf -> unit
val read_bool : lexer_state -> Lexing.lexbuf -> bool
val read_int : lexer_state -> Lexing.lexbuf -> int
val read_number : lexer_state -> Lexing.lexbuf -> [> `Float of float ]
val read_string : lexer_state -> Lexing.lexbuf -> string
val read_ident : lexer_state -> Lexing.lexbuf -> string

val read_sequence :
  ('a -> lexer_state -> Lexing.lexbuf -> 'a) ->
  'a ->
  lexer_state ->
  Lexing.lexbuf -> 'a

val read_list :
  (lexer_state -> Lexing.lexbuf -> 'a) ->
  lexer_state ->
  Lexing.lexbuf -> 'a list

val read_list_rev :
  (lexer_state -> Lexing.lexbuf -> 'a) ->
  lexer_state ->
  Lexing.lexbuf -> 'a list

val read_array_end : Lexing.lexbuf -> unit
val read_array_sep : lexer_state -> Lexing.lexbuf -> unit

val read_array :
  (lexer_state -> Lexing.lexbuf -> 'a) ->
  lexer_state ->
  Lexing.lexbuf -> 'a array

val read_tuple :
  (int -> 'a -> lexer_state -> Lexing.lexbuf -> 'a) ->
  'a ->
  lexer_state ->
  Lexing.lexbuf -> 'a

val read_tuple_end : Lexing.lexbuf -> unit
val read_tuple_sep : lexer_state -> Lexing.lexbuf -> unit

val read_fields :
  ('a -> string -> lexer_state -> Lexing.lexbuf -> 'a) ->
  'a ->
  lexer_state ->
  Lexing.lexbuf -> 'a

val read_object_end : Lexing.lexbuf -> unit
val read_object_sep : lexer_state -> Lexing.lexbuf -> unit
val read_colon : lexer_state -> Lexing.lexbuf -> unit


val read_json : lexer_state -> Lexing.lexbuf -> json

val from_lexbuf :
  lexer_state ->
  ?stream:bool ->
  Lexing.lexbuf -> json

val from_string :
  ?buf:Buffer.t ->
  ?fname:string ->
  ?lnum:int ->
  string -> json

val from_channel :
  ?buf:Buffer.t ->
  ?fname:string ->
  ?lnum:int ->
  in_channel -> json

val from_file :
  ?buf:Buffer.t ->
  ?fname:string ->
  ?lnum:int ->
  string -> json


type json_line = [ `Json of json | `Exn of exn ]

val stream_from_lexbuf :
  lexer_state ->
  ?fin:(unit -> unit) ->
  Lexing.lexbuf -> json Stream.t

val stream_from_string :
  ?buf:Buffer.t ->
  ?fname:string ->
  ?lnum:int ->
  string -> json Stream.t

val stream_from_channel :
  ?buf:Buffer.t ->
  ?fin:(unit -> unit) ->
  ?fname:string ->
  ?lnum:int ->
  in_channel -> json Stream.t

val stream_from_file :
  ?buf:Buffer.t ->
  ?fname:string ->
  ?lnum:int ->
  string -> json Stream.t

val linestream_from_channel :
  ?buf:Buffer.t ->
  ?fin:(unit -> unit) ->
  ?fname:string ->
  ?lnum:int ->
  in_channel -> json_line Stream.t

val linestream_from_file :
  ?buf:Buffer.t ->
  ?fname:string ->
  ?lnum:int ->
  string -> json_line Stream.t
