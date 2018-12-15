exception Type_error of string * json

let typeof js =
  match project js with
  | `Assoc _ -> "object"
  | `Bool _ -> "bool"
  | `Float _ -> "float"
  | `Int _ -> "int"
  | `List _ -> "array"
  | `Null -> "null"
  | `String _ -> "string"
  | `Intlit _ -> "intlit"
  | `Tuple _ -> "tuple"
  | `Variant _ -> "variant"

let typerr msg js = raise (Type_error (msg ^ typeof js, js))

exception Undefined of string * json

let ( |> ) = ( |> )

let assoc name obj =
  try List.assoc name obj
  with Not_found -> inject `Null

let member name js =
  match project js with
  | `Assoc obj -> assoc name obj
  | _ -> typerr ("Can't get member '" ^ name ^ "' of non-object type ") js

let index i js =
  match project js with
  | `List l ->
      let len = List.length l in
      let wrapped_index = if i < 0 then len + i else i in
      if wrapped_index < 0 || wrapped_index >= len then
        raise (Undefined ("Index " ^ string_of_int i ^ " out of bounds", js))
      else List.nth l wrapped_index
  | _ -> typerr ("Can't get index " ^ string_of_int i
                 ^ " of non-array type ") js

let map f js =
#ifdef POSITION
  let (pos, x) = js in
  let posf v = (pos, v) in
#else
  let x = js in
  let posf v = v in
#endif
  match x with
  | `List l -> posf (`List (List.map f l))
  | _ -> typerr "Can't map function over non-array type " js

let to_assoc js =
  match project js with
  | `Assoc obj -> obj
  | _ -> typerr "Expected object, got " js

let to_option f js =
  match project js with
  | `Null -> None
  | _ -> Some (f js)

let to_bool js =
  match project js with
  | `Bool b -> b
  | _ -> typerr "Expected bool, got " js

let to_bool_option js =
  match project js with
  | `Bool b -> Some b
  | `Null -> None
  | _ -> typerr "Expected bool or null, got " js

let to_number js =
  match project js with
  | `Int i -> float i
  | `Float f -> f
  | _ -> typerr "Expected number, got " js

let to_number_option js =
  match project js with
  | `Int i -> Some (float i)
  | `Float f -> Some f
  | `Null -> None
  | _ -> typerr "Expected number or null, got " js

let to_float js =
  match project js with
  | `Float f -> f
  | _ -> typerr "Expected float, got " js

let to_float_option js =
  match project js with
  | `Float f -> Some f
  | `Null -> None
  | _ -> typerr "Expected float or null, got " js

let to_int js =
  match project js with
  | `Int i -> i
  | _ -> typerr "Expected int, got " js

let to_int_option js =
  match project js with
  | `Int i -> Some i
  | `Null -> None
  | _ -> typerr "Expected int or null, got " js

let to_list js =
  match project js with
  | `List l -> l
  | _ -> typerr "Expected array, got " js

let to_string js =
  match project js with
  | `String s -> s
  | _ -> typerr "Expected string, got " js

let to_string_option js =
  match project js with
  | `String s -> Some s
  | `Null -> None
  | _ -> typerr "Expected string or null, got " js

let convert_each f js =
  match project js with
  | `List l -> List.map f l
  | _ -> typerr "Can't convert each element of non-array type " js


let rec rev_filter_map f acc l =
  match l with
      [] -> acc
    | x :: tl ->
        match f x with
            None -> rev_filter_map f acc tl
          | Some y -> rev_filter_map f (y :: acc) tl

let filter_map f l =
  List.rev (rev_filter_map f [] l)

let rec rev_flatten acc l =
  match l with
      [] -> acc
    | js :: tl ->
        match project js with
            `List l2 -> rev_flatten (List.rev_append l2 acc) tl
          | _ -> rev_flatten acc tl

let flatten l =
  List.rev (rev_flatten [] l)

let filter_index i l =
  filter_map (fun js ->
    match project js with
        `List l ->
          (try Some (List.nth l i)
           with _ -> None)
      | _ -> None
  ) l

let filter_list l =
  filter_map (fun js ->
    match project js with
        `List l -> Some l
      | _ -> None
  ) l

let filter_member k l =
  filter_map (fun js ->
    match project js with
        `Assoc l ->
          (try Some (List.assoc k l)
           with _ -> None)
      | _ -> None
  ) l

let filter_assoc l =
  filter_map (fun js ->
    match project js with
        `Assoc l -> Some l
      | _ -> None
  ) l

let filter_bool l =
  filter_map (fun js ->
    match project js with
        `Bool x -> Some x
      | _ -> None
  ) l

let filter_int l =
  filter_map (fun js ->
    match project js with
        `Int x -> Some x
      | _ -> None
  ) l

let filter_float l =
  filter_map (fun js ->
    match project js with
        `Float x -> Some x
      | _ -> None
  ) l

let filter_number l =
  filter_map (fun js ->
    match project js with
        `Int x -> Some (float x)
      | `Float x -> Some x
      | _ -> None
  ) l

let filter_string l =
  filter_map (fun js ->
    match project js with
        `String x -> Some x
      | _ -> None
  ) l

#ifdef POSITION
let filter_bool_with_pos l =
  filter_map (fun (pos, v) ->
    match v with
        `Bool x -> Some (pos, x)
      | _ -> None
  ) l

let filter_int_with_pos l =
  filter_map (fun (pos, v) ->
    match v with
        `Int x -> Some (pos, x)
      | _ -> None
  ) l

let filter_float_with_pos l =
  filter_map (fun (pos, v) ->
    match v with
        `Float x -> Some (pos, x)
      | _ -> None
  ) l

let filter_number_with_pos l =
  filter_map (fun (pos, v) ->
    match v with
        `Int x -> Some (pos, float x)
      | `Float x -> Some (pos, x)
      | _ -> None
  ) l

let filter_string_with_pos l =
  filter_map (fun (pos, v) ->
    match v with
        `String x -> Some (pos, x)
      | _ -> None
  ) l
#endif

let keys o =
  to_assoc o |> List.map (fun (key, _) -> key)

let values o =
  to_assoc o |> List.map (fun (_, value) -> value)

let combine (first : json) (second : json) =
#ifdef POSITION
  let (pos, x) = first in
  let (_, y) = second in
  let f v = (pos, v) in
#else
  let x = first in
  let y = second in
  let f v = v in
#endif
  match (x, y) with
  | (`Assoc a, `Assoc b) -> (f (`Assoc (a @ b)) : json)
  | (_, _) -> raise (Invalid_argument "Expected two objects, check inputs")
