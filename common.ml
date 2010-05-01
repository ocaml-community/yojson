(* $Id$ *)

exception Json_error of string

let json_error s = raise (Json_error s)

type in_param = {
  string_buf : Buffer.t
}

let create_in_param ?(len = 256) () = {
  string_buf = Buffer.create len
}


let utf8_of_bytes buf a b c d =
  let i = (a lsl 12) lor (b lsl 8) lor (c lsl 4) lor d in
  if i < 0x80 then
    Buffer.add_char buf (Char.chr i)
  else if i < 0x800 then (
    Buffer.add_char buf (Char.chr (0xc0 lor ((i lsr 6) land 0x1f)));
    Buffer.add_char buf (Char.chr (0x80 lor (i land 0x3f)))
  )
  else (* i < 0x10000 *) (
    Buffer.add_char buf (Char.chr (0xe0 lor ((i lsr 12) land 0xf)));
    Buffer.add_char buf (Char.chr (0x80 lor ((i lsr 6) land 0x3f)));
    Buffer.add_char buf (Char.chr (0x80 lor (i land 0x3f)))
  )


let is_object_or_array x =
  match x with
      `List _
    | `Assoc _ -> true
    | _ -> false

