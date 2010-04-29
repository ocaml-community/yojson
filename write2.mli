(* $Id$ *)

val pretty_format : ?std:bool -> json -> Easy_format.t
val pretty_to_string : ?std:bool -> json -> string
val pretty_to_channel : ?std:bool -> out_channel -> json -> unit
