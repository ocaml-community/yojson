let rec to_basic (x : json) : Basic.json =
#ifdef POSITION
  let (_, x) = x in
#endif
  match x with
  | `Null
  | `Bool _
  | `Int _
  | `Float _
  | `String _ as x -> x
  | `Intlit s -> `String s
  | `List l
  | `Tuple l ->
      `List (List.rev (List.rev_map to_basic l))
  | `Assoc l ->
      `Assoc (List.rev (List.rev_map (fun (k, v) -> (k, to_basic v)) l))
  | `Variant (k, None) -> `String k
  | `Variant (k, Some v) -> `List [ `String k; to_basic v ]
