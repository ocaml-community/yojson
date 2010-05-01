(* $Id$ *)

exception Json_error of string

val json_error : string -> 'a

exception End_of_array
exception End_of_object
exception End_of_tuple
exception End_of_input
