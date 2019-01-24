val pp : Format.formatter -> t -> unit
  (** Pretty printer, useful for debugging *)

val show : t -> string
  (** Convert value to string, useful for debugging *)

val equal : t -> t -> bool
  (** [equal a b] is the monomorphic equality *)
