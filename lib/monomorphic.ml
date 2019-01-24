
let rec equal a b =
  match a, b with
  | `Null, `Null -> true
  | `Bool a, `Bool b -> a = b
#ifdef INT
  | `Int a, `Int b -> a = b
#endif
#ifdef INTLIT
    | `Intlit a, `Intlit b -> a = b
#endif
#ifdef FLOAT
    | `Float a, `Float b -> a = b
#endif
#ifdef FLOATLIT
    | `Floatlit a, `Floatlit b -> a = b
#endif
#ifdef STRING
    | `String a, `String b -> a = b
#endif
#ifdef STRINGLIT
    | `Stringlit a, `Stringlit b -> a = b
#endif
    | `Assoc xs, `Assoc ys ->
      (* determine whether a k exists in assoc that has value v *)
      let rec mem_value k v = function
        | [] -> false
        | (k', v')::xs ->
            match k = k' with
            | false -> mem_value k v xs
            | true ->
              match equal v v' with
              | true -> true
              | false -> mem_value k v xs
      in

      (match List.length xs = List.length ys with
      | false -> false
      | true ->
        List.fold_left (fun acc (k, v) ->
          match acc with
          | false -> false
          | true -> mem_value k v ys) true xs)
#ifdef TUPLE
    | `Tuple xs, `Tuple ys
#endif
    | `List xs, `List ys ->
      (match List.length xs = List.length ys with
      | false -> false
      | true ->
        List.fold_left2 (fun acc x y ->
          match acc with
          | false -> false
          | true -> equal x y) true xs ys)
#ifdef VARIANT
    | `Variant (name, value), `Variant (name', value') ->
      (match name = name' with
      | false -> false
      | true ->
        match value, value' with
        | None, None -> true
        | Some x, Some y -> equal x y
        | _ -> false)
#endif
    | _ -> false
