(*
   Pretty-print JSON data in an attempt to maximize readability.

   1. What fits on one line stays on one line.
   2. What doesn't fit on one line gets printed more vertically so as to not
      exceed a reasonable page width, if possible.

   Arrays containing only simple elements ("atoms") are pretty-printed with
   end-of-line wrapping like ordinary text:

     [
        "hello", "hello", "hello", "hello", "hello", "hello", "hello", "hello",
        "hello", "hello", "hello", "hello", "hello", "hello", "hello", "hello"
     ]

   Other arrays are printed either horizontally or vertically depending
   on whether they fit on a single line:

     [ { "hello": "world" }, { "hello": "world" }, { "hello": "world" } ]

   or

     [
       { "hello": "world" },
       { "hello": "world" },
       { "hello": "world" },
       { "hello": "world" }
     ]
*)

let pp_list sep ppx out l =
  let pp_sep out () = Format.fprintf out "%s@ " sep in
  Format.pp_print_list ~pp_sep ppx out l

let is_atom (x: [> t]) =
  match x with
  | `Null
  | `Bool _
  | `Int _
  | `Float _
  | `String _
  | `Intlit _
  | `Floatlit _
  | `Stringlit _
  | `List []
  | `Assoc [] -> true
  | `List _
  | `Assoc _ -> false

let is_atom_list l =
  List.for_all is_atom l

(*
   inside_box: indicates that we're already within a box that imposes
   a certain style and we shouldn't create a new one. This is used for
   printing field values like this:

     foo: [
       bar
     ]

   rather than something else like

     foo:
       [
         bar
       ]
*)
let rec format ~inside_box (out : Format.formatter) (x : t) : unit =
  match x with
    | `Null -> Format.pp_print_string out "null"
    | `Bool x -> Format.pp_print_bool out x
#ifdef INT
    | `Int x -> Format.pp_print_string out (json_string_of_int x)
#endif
#ifdef FLOAT
    | `Float x ->
        Format.pp_print_string out (json_string_of_float x)
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
      if not inside_box then Format.fprintf out "@[<hv2>";
      if is_atom_list l then
        (* use line wrapping like we would do for a paragraph of text *)
        Format.fprintf out "[@;<1 0>@[<hov>%a@]@;<1 -2>]"
          (pp_list "," (format ~inside_box:false)) l
      else
        (* print the elements horizontally if they fit on the line,
           otherwise print them in a column *)
        Format.fprintf out "[@;<1 0>@[<hv>%a@]@;<1 -2>]"
          (pp_list "," (format ~inside_box:false)) l;
      if not inside_box then Format.fprintf out "@]";
    | `Assoc [] -> Format.pp_print_string out "{}"
    | `Assoc l ->
      if not inside_box then Format.fprintf out "@[<hv2>";
      Format.fprintf out "{@;<1 0>%a@;<1 -2>}" (pp_list "," (format_field)) l;
      if not inside_box then Format.fprintf out "@]";

and format_field out (name, x) =
  Format.fprintf out "@[<hv2>%s: %a@]" (json_string_of_string name) (format ~inside_box:true) x

(* [std] argument to be deprecated *)
let pp ?(std = true) out x =
  Format.fprintf out "@[<hv2>%a@]" (format ~inside_box:true) (x :> t)

let to_string ?std x =
  Format.asprintf "%a" (pp ?std) x

let to_channel ?std oc x =
  let fmt = Format.formatter_of_out_channel oc in
  Format.fprintf fmt "%a@?" (pp ?std) x
