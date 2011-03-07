(* $Id$ *)

exception Json_error of string

let json_error s = raise (Json_error s)

exception End_of_array
exception End_of_object
exception End_of_tuple
exception End_of_input

type in_param = {
  string_buf : Buffer.t
}

let create_in_param ?(len = 256) () = {
  string_buf = Buffer.create len
}


let utf8_of_bytes buf a b c d =
  let i = (a lsl 12) lor (b lsl 8) lor (c lsl 4) lor d in
  if i < 0x80 then
    Bi_outbuf.add_char buf (Char.chr i)
  else if i < 0x800 then (
    Bi_outbuf.add_char buf (Char.chr (0xc0 lor ((i lsr 6) land 0x1f)));
    Bi_outbuf.add_char buf (Char.chr (0x80 lor (i land 0x3f)))
  )
  else (* i < 0x10000 *) (
    Bi_outbuf.add_char buf (Char.chr (0xe0 lor ((i lsr 12) land 0xf)));
    Bi_outbuf.add_char buf (Char.chr (0x80 lor ((i lsr 6) land 0x3f)));
    Bi_outbuf.add_char buf (Char.chr (0x80 lor (i land 0x3f)))
  )


let is_object_or_array x =
  match x with
      `List _
    | `Assoc _ -> true
    | _ -> false


type lexer_state = {
  buf : Bi_outbuf.t;
    (* Buffer used to accumulate substrings *)

  mutable lnum : int;
    (* Current line number (starting from 1) *)

  mutable bol : int;
    (* Absolute position of the first character of the current line 
       (starting from 0) *)

  mutable fname : string option;
    (* Name describing the input file *)
}

module Lexer_state =
struct
  type t = lexer_state = {
    buf : Bi_outbuf.t;
    mutable lnum : int;
    mutable bol : int;
    mutable fname : string option;
  }
end

let init_lexer ?buf ?fname ?(lnum = 1) () =
  let buf =
    match buf with
	None -> Bi_outbuf.create 256
      | Some buf -> buf
  in
  {
    buf = buf;
    lnum = lnum;
    bol = 0;
    fname = fname
  }
