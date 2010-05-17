(* $Id$ *)

(** {3 JSON writers} *)

val to_string :
  ?buf:Bi_outbuf.t ->
  ?len:int ->
  ?std:bool ->
  json -> string

val to_channel :
  ?buf:Bi_outbuf.t ->
  ?len:int ->
  ?std:bool ->
  out_channel -> json -> unit

val to_file :
  ?buf:Bi_outbuf.t ->
  ?len:int ->
  ?std:bool ->
  string -> json -> unit


(**/**)
(* begin undocumented section *)

val write_null : Bi_outbuf.t -> unit -> unit
val write_bool : Bi_outbuf.t -> bool -> unit
#ifdef INT
val write_int : Bi_outbuf.t -> int -> unit
#endif
#ifdef FLOAT
val write_float : Bi_outbuf.t -> float -> unit
#endif
#ifdef STRING
val write_string : Bi_outbuf.t -> string -> unit
#endif

#ifdef INTLIT
val write_intlit : Bi_outbuf.t -> string -> unit
#endif
#ifdef FLOATLIT
val write_floatlit : Bi_outbuf.t -> string -> unit
#endif
#ifdef STRINGLIT
val write_stringlit : Bi_outbuf.t -> string -> unit
#endif

val write_assoc : Bi_outbuf.t -> (string * json) list -> unit
val write_list : Bi_outbuf.t -> json list -> unit
#ifdef TUPLE
val write_tuple : Bi_outbuf.t -> json list -> unit
val write_std_tuple : Bi_outbuf.t -> json list -> unit
#endif
#ifdef VARIANT
val write_variant : Bi_outbuf.t -> string -> json option -> unit
val write_std_variant : Bi_outbuf.t -> string -> json option -> unit
#endif


val write_json : Bi_outbuf.t -> json -> unit
val write_std_json : Bi_outbuf.t -> json -> unit

(* end undocumented section *)
(**/**)
