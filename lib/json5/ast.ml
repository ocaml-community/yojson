type internal =
  | Assoc of (string * internal) list
  | List of internal list
  | StringLit of string
  | IntLit of string
  | FloatLit of string
  | Bool of bool
  | Null

let strip_quotes s = String.(sub s 1 (length s - 2))

let safe_strip_quotes s =
  if String.(get s 0 = '"' && get s (length s - 1) = '"') then strip_quotes s
  else s

let rec to_basic = function
  | Assoc l ->
      `Assoc
        (List.map (fun (name, obj) -> (safe_strip_quotes name, to_basic obj)) l)
  | List l -> `List (List.map to_basic l)
  | StringLit s -> `String (strip_quotes s)
  | FloatLit s -> `Float (float_of_string s)
  | IntLit s -> `Int (int_of_string s)
  | Bool b -> `Bool b
  | Null -> `Null

let rec to_safe = function
  | Assoc l ->
      `Assoc
        (List.map (fun (name, obj) -> (safe_strip_quotes name, to_safe obj)) l)
  | List l -> `List (List.map to_safe l)
  | StringLit s -> `String (strip_quotes s)
  | FloatLit s -> `Float (float_of_string s)
  | IntLit s -> (
      match int_of_string_opt s with Some i -> `Int i | None -> `Intlit s)
  | Bool b -> `Bool b
  | Null -> `Null
