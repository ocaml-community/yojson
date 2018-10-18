#ifdef POSITION
  let project (_, x) = x

  let inject x =
    let dummy =
      {
        file_name = Some "(dummy)";
        start_line = 0;
        start_column = 0;
      }
    in
    (dummy, x)

  let rec forget_positions ((_, x) : json) =
    match x with
    | `Null -> `Null
    | `Bool b -> `Bool b
  #ifdef INT
    | `Int i -> `Int i
  #endif
  #ifdef INTLIT
    | `Intlit s -> `Intlit s
  #endif
  #ifdef FLOAT
    | `Float r -> `Float r
  #endif
  #ifdef FLOATLIT
    | `Floatlit s -> `Floatlit s
  #endif
  #ifdef STRING
    | `String s -> `String s
  #endif
  #ifdef STRINGLIT
    | `Stringlit s -> `Stringlit s
  #endif
    | `Assoc assoc -> `Assoc (assoc |> List.map (fun (k, v) -> (k, forget_positions v)))
    | `List js -> `List (js |> List.map forget_positions)
  #ifdef TUPLE
    | `Tuple js -> `Tuple (js |> List.map forget_positions)
  #endif
  #ifdef VARIANT
    | `Variant (s, jopt) ->
        begin
          match jopt with
          | None -> `Variant (s, None)
          | Some(j) -> `Variant (s, Some(forget_positions j))
        end
  #endif
#else
  let project x = x

  let inject x = x
#endif
