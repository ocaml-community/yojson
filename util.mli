(** {2 Utility functions for data access} *)

exception Type_error of string * json
  (** Raised when the JSON value is not of the correct type to support an
      operation, e.g. [member] on an [`Int]. The string message explains the
      mismatch. *)

exception Undefined of string * json
  (** Raised when the equivalent JavaScript operation on the JSON value would
      return undefined. Currently this only happens when an array index is out
      of bounds. *)

val ( |> ) : 'a -> ('a -> 'b) -> 'b
  (** Forward pipe operator; useful for composing JSON access functions
      without too many parentheses *)

val member : string -> json -> json
  (** [member k obj] returns the value associated with the key [k] in the JSON
      object [obj], or [`Null] if [k] is not present in [obj]. *)

val index : int -> json -> json
  (** [index i arr] returns the value at index [i] in the JSON array [arr].
      Negative indices count from the end of the list (so -1 is the last
      element). *)

val map : (json -> json) -> json -> json
  (** [map f arr] calls the function [f] on each element of the JSON array
      [arr], and returns a JSON array containing the results. *)

val to_assoc : json -> (string * json) list
  (** Extract the items of a JSON array or raise [Type_error]. *)

val to_option : (json -> 'a) -> json -> 'a option
  (** Return [None] if the JSON value is null or map the JSON value
      to [Some] value using the provided function. *)

val to_bool : json -> bool
  (** Extract a boolean value or raise [Type_error]. *)

val to_bool_option : json -> bool option
  (** Extract [Some] boolean value, 
      return [None] if the value is null,
      or raise [Type_error] otherwise. *)

val to_number : json -> float
  (** Extract a number or raise [Type_error]. *)

val to_number_option : json -> float option
  (** Extract [Some] number, 
      return [None] if the value is null,
      or raise [Type_error] otherwise. *)

val to_float : json -> float
  (** Extract a float value or raise [Type_error].
      [to_number] is generally preferred as it also works with int literals. *)

val to_float_option : json -> float option
  (** Extract [Some] float value, 
      return [None] if the value is null,
      or raise [Type_error] otherwise.
      [to_number_option] is generally preferred as it also works
      with int literals. *)

val to_int : json -> int
  (** Extract an int from a JSON int or raise [Type_error]. *)

val to_int_option : json -> int option
  (** Extract [Some] int from a JSON int, 
      return [None] if the value is null,
      or raise [Type_error] otherwise. *)

val to_list : json -> json list
  (** Extract a list from JSON array or raise [Type_error]. *)

val to_string : json -> string
  (** Extract a string from a JSON string or raise [Type_error]. *)

val to_string_option : json -> string option
  (** Extract [Some] string from a JSON string, 
      return [None] if the value is null,
      or raise [Type_error] otherwise. *)

val convert_each : (json -> 'a) -> json -> 'a list
  (** The conversion functions above cannot be used with [map], because they do
      not return JSON values. This convenience function [convert_each to_f arr]
      is equivalent to [List.map to_f (to_list arr)]. *)
