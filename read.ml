(* $Id$ *)

open Bi_inbuf

let dec c =
  Char.code c - 48

let rec read ib =
  read_whitespace ib;
  let avail = Bi_inbuf.try_preread ib 256 in
  match Bi_inbuf.read_char ib with
    | 'n' -> read_null ib
    | 't' -> read_true ib
    | 'f' -> read_false ib
    | '0'..'9' as c -> read_number ib 255 (dec c)
    | '-' -> 
	(match Bi_inbuf.read_char ib with
	     '0'..'9' as c -> read_neg_number ib 255 (dec c)
	   | 'I' -> read_neg_infinity ib)
    | 'N' -> read_nan ib
    | 'I' -> read_infinity ib
#ifdef STRING
    | '"' -> read_string ib
#endif
#ifdef STRINGLIT
    | '"' -> read_stringlit ib
#endif
    | '{' -> read_assoc ib
    | '[' -> read_list ib
#ifdef TUPLE
    | '(' -> read_tuple ib
#endif
#ifdef VARIANT
    | '<' -> read_variant ib
#endif

and read_number ib avail accu =
  match Bi_inbuf.peek ib with
      '0'..'9' -> 
    | ...
