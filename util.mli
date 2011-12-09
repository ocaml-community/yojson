(** {2 Utility functions for data access} *)

(** Raised when the JSON value is not of the correct type to support an
    operation, e.g. [member] on an [`Int]. The string message explains the
    mismatch. *)
exception Type_error of string * json

(** Raised when the equivalent JavaScript operation on the JSON value would
    return undefined. Currently this only happens when an array index is out
    of bounds. *)
exception Undefined of string * json

(** Forward pipe operator; useful for composing JSON access functions
    without too many parentheses *)
val ( |> ) : 'a -> ('a -> 'b) -> 'b

(** [member k obj] returns the value associated with the key [k] in the JSON
object [obj], or [`Null] if [k] is not present in [obj]. *)
val member : string -> json -> json

(** [index i arr] returns the value at index [i] in the JSON array [arr].
    Negative indices count from the end of the list (so -1 is the last
    element). *)
val index : int -> json -> json

(** [map f arr] calls the function [f] on each element of the JSON array
    [arr], and returns a JSON array containing the results. *)
val map : (json -> json) -> json -> json

val to_assoc : json -> (string * json) list
val to_bool : json -> bool
val to_bool_option : json -> bool option
val to_float : json -> float
val to_float_option : json -> float option
val to_int : json -> int
val to_int_option : json -> int option
val to_list : json -> json list
val to_string : json -> string
val to_string_option : json -> string option

(** The conversion functions above cannot be used with [map], because they do
    not return JSON values. This convenience function [convert_each to_f arr]
    is equivalent to [List.map to_f (to_list arr)]. *)
val convert_each : (json -> 'a) -> json -> 'a list
