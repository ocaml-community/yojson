(* $Id$ *)

(* included: type.ml *)

open Bi_outbuf

let hex n =
  Char.chr (
    if n < 10 then n + 48
    else n + 87
  )

let write_special src start stop ob str =
  Bi_outbuf.blit src !start (stop - !start) ob;
  Bi_outbuf.add_string ob str;
  start := stop + 1

let write_control_char src start stop ob c =
  Bi_outbuf.blit src !start (stop - !start) ob;
  let i = Bi_outbuf.alloc ob 6 in
  let dst = ob.o_s in
  String.blit "\\u00" 0 dst i 4;
  dst.[i+4] <- hex (Char.code c lsr 4);
  dst.[i+5] <- hex (Char.code c land 0xf);
  start := stop + 1

let finish_string src start ob =
  Bi_outbuf.blit src !start (String.length src - !start) ob

let write_string_body ob s =
  let start = ref 0 in
  for i = 0 to String.length s - 1 do
    match s.[i] with
	'"' -> write_special s start i ob "\\\""
      | '\\' -> write_special s start i ob "\\\\"
      | '\b' -> write_special s start i ob "\\b"
      | '\012' -> write_special s start i ob "\\f"
      | '\n' -> write_special s start i ob "\\n"
      | '\r' -> write_special s start i ob "\\r"
      | '\t' -> write_special s start i ob "\\t"
      | '\x00'..'\x1F'
      | '\x7F' as c -> write_control_char s start i ob c
      | _ -> ()
  done;
  finish_string s start ob

let write_string ob s =
  Bi_outbuf.add_char ob '"';
  write_string_body ob s;
  Bi_outbuf.add_char ob '"'

let test_string () =
  let s = String.create 256 in
  for i = 0 to 255 do
    s.[i] <- Char.chr i
  done;
  let ob = Bi_outbuf.create 10 in
  write_string ob s;
  Bi_outbuf.contents ob


let write_null ob () =
  Bi_outbuf.add_string ob "null"

let write_bool ob x =
  Bi_outbuf.add_string ob (if x then "true" else "false")


let max_digits =
  max
    (String.length (string_of_int max_int))
    (String.length (string_of_int min_int))

let dec n =
  Char.chr (n + 48)

let rec write_digits s pos x =
  if x = 0 then pos
  else
    let d = x mod 10 in
    let pos = write_digits s pos (x / 10) in
    s.[pos] <- dec d;
    pos + 1

let write_int ob x =
  Bi_outbuf.extend ob max_digits;
  if x > 0 then
    ob.o_len <- write_digits ob.o_s ob.o_len x
  else if x < 0 then (
    Bi_outbuf.add_char ob '-';
    ob.o_len <- write_digits ob.o_s (ob.o_len + 1) (abs x)
  )
  else (
    Bi_outbuf.add_char ob '0';
    ob.o_len <- ob.o_len + 1
  )

let json_float_of_float x =
  match classify_float x with
      FP_normal
    | FP_subnormal ->
	Printf.sprintf "%.17g" x (* works well except that
				    integers are printed as ints *)
    | FP_zero -> "0.0"
    | FP_infinite -> if x > 0. then "Infinity" else "-Infinity"
    | FP_nan -> "NaN"

let write_float ob x =
  Bi_outbuf.add_string ob (json_float_of_float x)

let test_float () =
  let l = [ 0.; 1.; -1. ] in
  let l = l @ List.map (fun x -> 2. *. x +. 1.) l in
  let l = l @ List.map (fun x -> x /. sqrt 2.) l in
  let l = l @ List.map (fun x -> x *. sqrt 3.) l in
  let l = l @ List.map cos l in
  let l = l @ List.map (fun x -> x *. 1.23e50) l in
  let l = l @ [ infinity; neg_infinity ] in
  List.iter (
    fun x -> 
      let s = Printf.sprintf "%.17g" x in
      let y = float_of_string s in
      Printf.printf "%g %g %S %B\n" x y s (x = y)
  )
    l

(*
let () = test_float ()
*)

let write_intlit = Bi_outbuf.add_string
let write_floatlit = Bi_outbuf.add_string
let write_stringlit = Bi_outbuf.add_string
