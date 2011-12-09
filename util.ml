exception Type_error of string * json

let typeof = function
  | `Assoc _ -> "object"
  | `Bool _ -> "bool"
  | `Float _ -> "float"
  | `Int _ -> "int"
  | `List _ -> "array"
  | `Null -> "null"
  | `String _ -> "string"

let typerr msg js = raise (Type_error (msg ^ typeof js, js))

exception Undefined of string * json

let ( |> ) x f = f x

let assoc name obj =
  try List.assoc name obj
  with Not_found -> `Null

let member name = function
  | `Assoc obj -> assoc name obj
  | js -> typerr ("Can't get member '" ^ name ^ "' of non-object type ") js

let index i = function
  | `List l as js ->
      let len = List.length l in
      let wrapped_index = if i < 0 then len + i else i in
      if wrapped_index < 0 || wrapped_index >= len then
        raise (Undefined ("Index " ^ string_of_int i ^ " out of bounds", js))
      else List.nth l wrapped_index
  | js -> typerr ("Can't get index " ^ string_of_int i
                 ^ " of non-array type ") js

let map f = function
  | `List l -> `List (List.map f l)
  | js -> typerr "Can't map function over non-array type " js

let to_assoc = function
  | `Assoc obj -> obj
  | js -> typerr "Expected object, got " js

let to_bool = function
  | `Bool b -> b
  | js -> typerr "Expected bool, got " js

let to_bool_option = function
  | `Bool b -> Some b
  | `Null -> None
  | js -> typerr "Expected bool or null, got " js

let to_float = function
  | `Float f -> f
  | js -> typerr "Expected float, got " js

let to_float_option = function
  | `Float f -> Some f
  | `Null -> None
  | js -> typerr "Expected float or null, got " js

let to_int = function
  | `Int i -> i
  | js -> typerr "Expected int, got " js

let to_int_option = function
  | `Int i -> Some i
  | `Null -> None
  | js -> typerr "Expected int or null, got " js

let to_list = function
  | `List l -> l
  | js -> typerr "Expected array, got " js

let to_string = function
  | `String s -> s
  | js -> typerr "Expected string, got " js

let to_string_option = function
  | `String s -> Some s
  | `Null -> None
  | js -> typerr "Expected string or null, got " js

let convert_each f = function
  | `List l -> List.map f l
  | js -> typerr "Can't convert each element of non-array type " js
