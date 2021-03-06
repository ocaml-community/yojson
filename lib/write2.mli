(** {2 JSON pretty-printing} *)

val pretty_print : ?std:bool -> Format.formatter -> t -> unit
  (** Pretty-print into a {!Format.formatter}.
      See [to_string] for the role of the optional [std] argument.

      @since 1.3.1 *)

val pretty_to_string : ?std:bool -> t -> string
  (** Pretty-print into a string.
      See [to_string] for the role of the optional [std] argument.
  *)

val pretty_to_channel : ?std:bool -> out_channel -> t -> unit
  (** Pretty-print to a channel.
      See [to_string] for the role of the optional [std] argument.
  *)
