(** Shared test fixtures *)

val json_value : Yojson.Safe.t
(** A json value to use for testing *)

val json_string : string
(** A JSON string that must parse to [json_value] *)

val json_string_newline : string
(** The same JSON string terminated with a newline *)

val unquoted_json : string
val unquoted_value : Yojson.Safe.t
