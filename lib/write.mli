(** {2 JSON writers} *)

val to_string :
  ?buf:Buffer.t ->
  ?len:int ->
  ?std:bool ->
  t -> string
  (** Write a compact JSON value to a string.
      @param buf allows to reuse an existing buffer created with
      [Buffer.create]. The buffer is cleared of all contents
      before starting and right before returning.
      @param len initial length of the output buffer.
      @param std use only standard JSON syntax,
      i.e. convert tuples and variants into standard JSON (if applicable),
      refuse to print NaN and infinities,
      require the root node to be either an object or an array.
      Default is [false].
  *)

val to_channel :
  ?buf:Buffer.t ->
  ?len:int ->
  ?std:bool ->
  out_channel -> t -> unit
  (** Write a compact JSON value to a channel.
      @param buf allows to reuse an existing buffer created with
      [Buffer.create] on the same channel.
      [buf] is flushed right
      before [to_channel] returns but the [out_channel] is
      not flushed automatically.

      See [to_string] for the role of the other optional arguments. *)

val to_output :
  ?buf:Buffer.t ->
  ?len:int ->
  ?std:bool ->
  < output : string -> int -> int -> int; .. > -> t -> unit
  (** Write a compact JSON value to an OO channel.
      @param buf allows to reuse an existing buffer created with
      [Buffer.add_channel] on the same channel.
      [buf] is flushed right
      before [to_output] returns but the channel itself is
      not flushed automatically.

      See [to_string] for the role of the other optional arguments. *)

val to_file :
  ?len:int ->
  ?std:bool ->
  string -> t -> unit
  (** Write a compact JSON value to a file.
      See [to_string] for the role of the optional arguments. *)

val to_outbuf :
  ?std:bool ->
  Buffer.t -> t -> unit
  (** Write a compact JSON value to an existing buffer.
      See [to_string] for the role of the optional argument. *)

val stream_to_string :
  ?buf:Buffer.t ->
  ?len:int ->
  ?std:bool ->
  t Stream.t -> string
  (** Write a newline-separated sequence of compact one-line JSON values to
      a string.
      See [to_string] for the role of the optional arguments. *)

val stream_to_channel :
  ?buf:Buffer.t ->
  ?len:int ->
  ?std:bool ->
  out_channel -> t Stream.t -> unit
  (** Write a newline-separated sequence of compact one-line JSON values to
      a channel.
      See [to_channel] for the role of the optional arguments. *)

val stream_to_file :
  ?len:int ->
  ?std:bool ->
  string -> t Stream.t -> unit
  (** Write a newline-separated sequence of compact one-line JSON values to
      a file.
      See [to_string] for the role of the optional arguments. *)

val stream_to_outbuf :
  ?std:bool ->
  Buffer.t ->
  t Stream.t -> unit
  (** Write a newline-separated sequence of compact one-line JSON values to
      an existing buffer.
      See [to_string] for the role of the optional arguments. *)

val write_t : Bi_outbuf.t -> t -> unit
(** Write the given JSON value to the given buffer.
    Provided as a writer function for atdgen.
*)

(** {2 Miscellaneous} *)

val sort : t -> t
  (** Sort object fields (stable sort, comparing field names
      and treating them as byte sequences) *)


(**/**)
(* begin undocumented section *)

val write_null : Buffer.t -> unit -> unit
val write_bool : Buffer.t -> bool -> unit
#ifdef INT
val write_int : Buffer.t -> int -> unit
#endif
#ifdef FLOAT
val write_float : Buffer.t -> float -> unit
val write_std_float : Buffer.t -> float -> unit
val write_float_fast : Buffer.t -> float -> unit
val write_std_float_fast : Buffer.t -> float -> unit
val write_float_prec : int -> Buffer.t -> float -> unit
val write_std_float_prec : int -> Buffer.t -> float -> unit
#endif
#ifdef STRING
val write_string : Buffer.t -> string -> unit
#endif

#ifdef INTLIT
val write_intlit : Buffer.t -> string -> unit
#endif
#ifdef FLOATLIT
val write_floatlit : Buffer.t -> string -> unit
#endif
#ifdef STRINGLIT
val write_stringlit : Buffer.t -> string -> unit
#endif

val write_assoc : Buffer.t -> (string * t) list -> unit
val write_list : Buffer.t -> t list -> unit
#ifdef TUPLE
val write_tuple : Buffer.t -> t list -> unit
val write_std_tuple : Buffer.t -> t list -> unit
#endif
#ifdef VARIANT
val write_variant : Buffer.t -> string -> t option -> unit
val write_std_variant : Buffer.t -> string -> t option -> unit
#endif

val write_json : Buffer.t -> t -> unit
val write_std_json : Buffer.t -> t -> unit

(* end undocumented section *)
(**/**)
