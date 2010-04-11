(* $Id$ *)

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

