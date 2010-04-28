(* $Id$ *)

exception Json_error of string

val json_error : string -> 'a
