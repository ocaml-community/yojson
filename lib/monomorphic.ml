let rec pp fmt =
  function
  | `Null -> Format.pp_print_string fmt "`Null"
  | `Bool x ->
    Format.fprintf fmt "`Bool (@[<hov>";
    Format.fprintf fmt "%B" x;
    Format.fprintf fmt "@])"
#ifdef INT
  | `Int x ->
    Format.fprintf fmt "`Int (@[<hov>";
    Format.fprintf fmt "%d" x;
    Format.fprintf fmt "@])"
#endif
#ifdef INTLIT
  | `Intlit x ->
    Format.fprintf fmt "`Intlit (@[<hov>";
    Format.fprintf fmt "%S" x;
    Format.fprintf fmt "@])"
#endif
#ifdef FLOAT
  | `Float x ->
    Format.fprintf fmt "`Float (@[<hov>";
    Format.fprintf fmt "%F" x;
    Format.fprintf fmt "@])"
#endif
#ifdef FLOATLIT
  | `Floatlit x ->
    Format.fprintf fmt "`Floatlit (@[<hov>";
    Format.fprintf fmt "%S" x;
    Format.fprintf fmt "@])"
#endif
#ifdef STRING
  | `String x ->
    Format.fprintf fmt "`String (@[<hov>";
    Format.fprintf fmt "%S" x;
    Format.fprintf fmt "@])"
#endif
#ifdef STRINGLIT
  | `Stringlit x ->
    Format.fprintf fmt "`Stringlit (@[<hov>";
    Format.fprintf fmt "%S" x;
    Format.fprintf fmt "@])"
#endif
  | `Assoc xs ->
    Format.fprintf fmt "`Assoc (@[<hov>";
    Format.fprintf fmt "@[<2>[";
    ignore (List.fold_left
      (fun sep (key, value) ->
        if sep then
          Format.fprintf fmt ";@ ";
          Format.fprintf fmt "(@[";
          Format.fprintf fmt "%S" key;
          Format.fprintf fmt ",@ ";
          pp fmt value;
          Format.fprintf fmt "@])";
          true) false xs);
    Format.fprintf fmt "@,]@]";
    Format.fprintf fmt "@])"
  | `List xs ->
    Format.fprintf fmt "`List (@[<hov>";
    Format.fprintf fmt "@[<2>[";
    ignore (List.fold_left
      (fun sep x ->
        if sep then
          Format.fprintf fmt ";@ ";
          pp fmt x;
          true) false xs);
    Format.fprintf fmt "@,]@]";
    Format.fprintf fmt "@])"

let show x =
  Format.asprintf "%a" pp x

let equal a b =
  #include "equal.cppo.ml"
  in
  equal a b

let numeric_equal a b =
  #define NUMERIC_EQUAL
    #include "equal.cppo.ml"
  #undef NUMERIC_EQUAL
  in
  equal a b
