let rec equal a b =
  let [@warning "-26"] float_int_equal f i = (float_of_int i) = f in
  match a, b with
  | `Null, `Null -> true
  | `Bool a, `Bool b -> a = b
#ifdef INT
  | `Int a, `Int b -> a = b
#endif
#ifdef INTLIT
    | `Intlit a, `Intlit b -> a = b
  #ifdef NUMERIC_EQUAL
    #ifdef INT
    | `Intlit s, `Int i
    | `Int i, `Intlit s -> (string_of_int i) = s
    #endif
  #endif
#endif
#ifdef FLOAT
    | `Float a, `Float b -> a = b
  #ifdef NUMERIC_EQUAL
    #ifdef INT
    | `Float f, `Int i
    | `Int i, `Float f -> float_int_equal f i
    #endif
  #endif
#endif
#ifdef FLOATLIT
    | `Floatlit a, `Floatlit b -> a = b
  #ifdef NUMERIC_EQUAL
    #ifdef FLOAT
    | `Floatlit l, `Float f
    | `Float f, `Floatlit l -> (string_of_float f) = l
    #endif
  #endif
#endif
#ifdef STRING
    | `String a, `String b -> a = b
#endif
#ifdef STRINGLIT
    | `Stringlit a, `Stringlit b -> a = b
#endif
    | `Assoc xs, `Assoc ys ->
      let compare_keys = fun (key, _) (key', _) -> String.compare key key' in
      let xs = List.stable_sort compare_keys xs in
      let ys = List.stable_sort compare_keys ys in
      (match List.for_all2 (fun (key, value) (key', value') ->
        match key = key' with
        | false -> false
        | true -> equal value value') xs ys with
      | result -> result
      | exception Invalid_argument _ ->
        (* the lists were of different lengths, thus unequal *)
        false)
    | `List xs, `List ys ->
      (match List.for_all2 equal xs ys with
      | result -> result
      | exception Invalid_argument _ ->
        (* the lists were of different lengths, thus unequal *)
        false)
    | _ -> false
