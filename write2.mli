(* $Id$ *)

val pretty_format : ?std:bool -> json -> Easy_format.t
  (** Convert into a pretty-printable tree.
      See [to_string] for the role of the optional [std] argument.

      @see <http://martin.jambon.free.fr/easy-format.html> Easy-format
  *)

val pretty_to_string : ?std:bool -> json -> string
  (** Pretty-print into a string.
      See [to_string] for the role of the optional [std] argument.
  *)

val pretty_to_channel : ?std:bool -> out_channel -> json -> unit
  (** Pretty-print to a channel.
      See [to_string] for the role of the optional [std] argument.
  *)
