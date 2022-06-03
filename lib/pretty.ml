
let pp_list sep ppx out l =
  let pp_sep out () = Format.fprintf out "%s@ " sep in
  Format.pp_print_list ~pp_sep ppx out l

let rec format inbox std (out:Format.formatter) (x:t) : unit =
  match x with
    | `Null -> Format.pp_print_string out "null"
    | `Bool x -> Format.pp_print_bool out x
#ifdef INT
    | `Int x -> Format.pp_print_string out (json_string_of_int x)
#endif
#ifdef FLOAT
    | `Float x ->
        let s =
          if std then std_json_string_of_float x
          else json_string_of_float x
        in
        Format.pp_print_string out s
#endif
#ifdef STRING
    | `String s -> Format.pp_print_string out (json_string_of_string s)
#endif
#ifdef INTLIT
    | `Intlit s -> Format.pp_print_string out s
#endif
#ifdef FLOATLIT
    | `Floatlit s -> Format.pp_print_string out s
#endif
#ifdef STRINGLIT
    | `Stringlit s -> Format.pp_print_string out s
#endif
    | `List [] -> Format.pp_print_string out "[]"
    | `List l ->
      if not inbox then Format.fprintf out "@[<hov2>";
      Format.fprintf out "[@;<1 0>@[<hov>%a@]@;<1 -2>]" (pp_list "," (format false std)) l;
      if not inbox then Format.fprintf out "@]";
    | `Assoc [] -> Format.pp_print_string out "{}"
    | `Assoc l ->
      if not inbox then Format.fprintf out "@[<hv2>";
      Format.fprintf out "{@;<1 0>%a@;<1 -2>}" (pp_list "," (format_field std)) l;
      if not inbox then Format.fprintf out "@]";
#ifdef TUPLE
    | `Tuple l ->
        if std then
          format inbox std out (`List l)
        else
          if l = [] then
            Format.pp_print_string out "()"
          else (
            if not inbox then Format.fprintf out "@[<hov2>";
            Format.fprintf out "(@,%a@;<0 -2>)" (pp_list "," (format false std)) l;
            if not inbox then Format.fprintf out "@]";
          )
#endif
#ifdef VARIANT
    | `Variant (s, None) ->
        if std then
#ifdef STRING
          let representation = `String s in
#elif defined STRINGLIT
          let representation = `Stringlit s in
#endif
          format inbox std out representation
        else
          Format.fprintf out "<%s>" (json_string_of_string s)

    | `Variant (s, Some x) ->
        if std then
#ifdef STRING
          let representation = `String s in
#elif defined STRINGLIT
          let representation = `Stringlit s in
#endif
          format inbox std out (`List [ representation; x ])
        else
          let op = json_string_of_string s in
          Format.fprintf out "<@[<hv2>%s: %a@]>" op (format true std) x
#endif

and format_field std out (name, x) =
  Format.fprintf out "@[<hv2>%s: %a@]" (json_string_of_string name) (format true std) x

let pp ?(std = false) out x =
  Format.fprintf out "@[<hv2>%a@]" (format true std) (x :> t)

let to_string ?std x =
  Format.asprintf "%a" (pp ?std) x

let to_channel ?std oc x =
  let fmt = Format.formatter_of_out_channel oc in
  Format.fprintf fmt "%a@?" (pp ?std) x
