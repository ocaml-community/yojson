(* $Id$ *)
{
  open Printf
  open Lexing

  let loc lexbuf = (lexbuf.lex_start_p, lexbuf.lex_curr_p)

  let string_of_loc (pos1, pos2) =
    let line1 = pos1.pos_lnum
    and start1 = pos1.pos_bol in
    Printf.sprintf "File %S, line %i, characters %i-%i"
      pos1.pos_fname line1
      (pos1.pos_cnum - start1)
      (pos2.pos_cnum - start1)
      
  let dec c =
    Char.code c - 48

  let hex c =
    match c with
	'0'..'9' -> int_of_char c - int_of_char '0'
      | 'a'..'f' -> int_of_char c - int_of_char 'a' + 10
      | 'A'..'F' -> int_of_char c - int_of_char 'A' + 10
      | _ -> assert false

  let custom_error descr lexbuf =
    json_error 
      (sprintf "%s:\n%s"
	 (string_of_loc (loc lexbuf))
         descr)

  let lexer_error descr lexbuf =
    custom_error 
      (sprintf "%s '%s'" descr (Lexing.lexeme lexbuf))
      lexbuf

  let min10 = min_int / 10 - (if min_int mod 10 = 0 then 0 else 1)
  let max10 = max_int / 10 + (if max_int mod 10 = 0 then 0 else 1)

  exception Int_overflow

  let extract_positive_int lexbuf =
    let start = lexbuf.lex_start_pos in
    let stop = lexbuf.lex_curr_pos in
    let s = lexbuf.lex_buffer in
    let n = ref 0 in
    for i = start to stop - 1 do
      if !n >= max10 then
	raise Int_overflow
      else
	n := 10 * !n + dec s.[i]
    done;
    if !n < 0 then
      raise Int_overflow
    else
      !n

  let make_positive_int lexbuf =
    try `Int (extract_positive_int lexbuf)
    with Int_overflow ->
      #ifdef INTLIT
	`Intlit (lexeme lexbuf)
      #else
        lexer_error "Int overflow" lexbuf
      #endif

  let extract_negative_int lexbuf =
    let start = lexbuf.lex_start_pos + 1 in
    let stop = lexbuf.lex_curr_pos in
    let s = lexbuf.lex_buffer in
    let n = ref 0 in
    for i = start to stop - 1 do
      if !n <= min10 then
	raise Int_overflow
      else
	n := 10 * !n - dec s.[i]
    done;
    if !n > 0 then
      raise Int_overflow
    else
      !n

  let make_negative_int lexbuf =
    try `Int (extract_negative_int lexbuf)
    with Int_overflow ->
      #ifdef INTLIT
	`Intlit (lexeme lexbuf)
      #else
        lexer_error "Int overflow" lexbuf
      #endif


  let set_file_name lexbuf name =
    lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = name }

  let newline lexbuf =
    let pos = lexbuf.lex_curr_p in
    lexbuf.lex_curr_p <- { pos with
			     pos_lnum = pos.pos_lnum + 1;
			     pos_bol = pos.pos_cnum }

  type param = {
    string_buf : Buffer.t
  }

  let add_lexeme buf lexbuf =
    let len = lexbuf.lex_curr_pos - lexbuf.lex_start_pos in
    Buffer.add_substring buf lexbuf.lex_buffer lexbuf.lex_start_pos len

  exception End_of_array
  exception End_of_object
}

let sp = [' ' '\t' '\r']*
let space = [' ' '\t' '\r']+

let digit = ['0'-'9']
let nonzero = ['1'-'9']
let digits = digit+
let frac = '.' digits
let e = ['e' 'E']['+' '-']?
let exp = e digits

let positive_int = (digit | nonzero digits)
let float = '-'? positive_int (frac | exp | frac exp)
let number = '-'? positive_int (frac | exp | frac exp)?

let hex = [ '0'-'9' 'a'-'f' 'A'-'F' ]

let unescaped = ['\x20'-'\x21' '\x23'-'\x5B' '\x5D'-'\xFF' ]

let ident = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '_' '0'-'9']*


rule read_json p = parse
  | "//"[^'\n']* { read_json p lexbuf }
  | "/*"         { finish_comment lexbuf; read_json p lexbuf }
  | '{'          { let acc = ref [] in
		   try
		     let field_name = read_field_name p lexbuf in
		     read_colon lexbuf;
		     acc := (field_name, read_json p lexbuf) :: !acc;
		     while true do
		       read_object_sep lexbuf;
		       let field_name = read_field_name p lexbuf in
		       read_colon lexbuf;
		       acc := (field_name, read_json p lexbuf) :: !acc;
		     done;
		     assert false
		   with End_of_object ->
		     `Assoc (List.rev !acc)
		 }

  | '['          { let acc = ref [] in
		   try
		     acc := read_json p lexbuf :: !acc;
		     while true do
		       read_array_sep lexbuf;
		       acc := read_json p lexbuf :: !acc;
		     done;
		     assert false
		   with End_of_array ->
		     `List (List.rev !acc)
		 }

  | "true"      { `Bool true }
  | "false"     { `Bool false }
  | "null"      { `Null }
  | "NaN"       { `Float nan }
  | "Infinity"  { `Float infinity }
  | "-Infinity" { `Float neg_infinity }
  | '"'         { let buf = p.string_buf in
		 Buffer.clear buf;
		 `String (finish_string buf lexbuf) }
  | positive_int         { make_positive_int lexbuf }
  | '-' positive_int     { make_negative_int lexbuf }
  | float       { `Float (float_of_string (lexeme lexbuf)) }
  | "\n"        { newline lexbuf; read_json p lexbuf }
  | space       { read_json p lexbuf }
  | eof         { raise End_of_file }
  | _           { lexer_error "Invalid token" lexbuf }


and finish_string buf = parse
    '"'         { Buffer.contents buf }
  | '\\'        { finish_escaped_char buf lexbuf;
		  finish_string buf lexbuf }
  | unescaped+  { add_lexeme buf lexbuf;
		  finish_string buf lexbuf }
  | _ as c      { custom_error 
		    (sprintf "Unescaped control character \\u%04X or \
                              unterminated string" (int_of_char c))
		    lexbuf }
  | eof         { custom_error "Unterminated string" lexbuf }


and finish_escaped_char buf = parse 
    '"'
  | '\\'
  | '/' as c { Buffer.add_char buf c }
  | 'b'  { Buffer.add_char buf '\b' }
  | 'f'  { Buffer.add_char buf '\012' }
  | 'n'  { Buffer.add_char buf '\n' }
  | 'r'  { Buffer.add_char buf '\r' }
  | 't'  { Buffer.add_char buf '\t' }
  | 'u' (hex as a) (hex as b) (hex as c) (hex as d)
         { utf8_of_bytes buf (hex a) (hex b) (hex c) (hex d) }
  | _    { lexer_error "Invalid escape sequence" lexbuf }


and finish_comment = parse
  | "*/" { () }
  | eof  { lexer_error "Unterminated comment" lexbuf }
  | '\n' { newline lexbuf; finish_comment lexbuf }
  | _    { finish_comment lexbuf }




(* Readers expecting a particular JSON construct *)

and read_null = parse
    sp "null"    { () }

and read_bool = parse
    sp "true"    { true }
  | sp "false"   { false }

and read_int = parse
    sp           { read_int_nospace lexbuf }

and read_int_nospace = parse
    positive_int         { try extract_positive_int lexbuf
			   with Int_overflow ->
			     lexer_error "Int overflow" lexbuf }
  | '-' positive_int     { try extract_negative_int lexbuf
			   with Int_overflow ->
			     lexer_error "Int overflow" lexbuf }
  
and read_number = parse
    sp           { read_number_nospace lexbuf }

and read_number_nospace = parse
  | "NaN"       { `Float nan }
  | "Infinity"  { `Float infinity }
  | "-Infinity" { `Float neg_infinity }
  | number      { `Float (float_of_string (lexeme lexbuf)) }

and read_string p = parse
    sp '"'      { let buf = p.string_buf in
		  Buffer.clear buf;
		  finish_string buf lexbuf }

and read_field_name p = parse
    sp '"'      { let buf = p.string_buf in
		  Buffer.clear buf;
		  finish_string buf lexbuf }
  | sp (ident as s)
                { s }

and read_sequence read_cell init_acc = parse
    sp '[' sp   { let acc = ref init_acc in
		  try
		    acc := read_cell !acc lexbuf;
		    while true do
		      read_array_sep lexbuf;
		      acc := read_cell !acc lexbuf;
		    done;
		    assert false
		  with End_of_array ->
		    !acc
		}

and read_list_rev read_cell = parse
    sp '[' sp   { let acc = ref [] in
		  try
		    acc := read_cell lexbuf :: !acc;
		    while true do
		      read_array_sep lexbuf;
		      acc := read_cell lexbuf :: !acc;
		    done;
		    assert false
		  with End_of_array ->
		    !acc
		}

and read_array_sep = parse
    sp ',' sp   { () }
  | sp ']'      { raise End_of_array }

and read_fields read_field init_acc p = parse
    sp '{' sp   { let acc = ref init_acc in
		  try
		    let field_name = read_field_name p lexbuf in
		    read_colon lexbuf;
		    acc := read_field !acc field_name lexbuf;
		    while true do
		      read_object_sep lexbuf;
		      let field_name = read_field_name p lexbuf in
		      read_colon lexbuf;
		      acc := read_field !acc field_name lexbuf;
		    done;
		    assert false
		  with End_of_object ->
		    !acc
		}

and read_object_sep = parse
    sp ',' sp   { () }
  | sp '}'      { raise End_of_object }

and read_colon = parse
    sp ':' sp   { () }

{
  let read_list read_cell lexbuf = List.rev (read_list_rev read_cell lexbuf)

  let array_of_rev_list l =
    match l with
	[] -> [| |]
      | x :: tl ->
	  let len = List.length l in
	  let a = Array.make len x in
	  let r = ref tl in
	  for i = len - 2 downto 0 do
	    a.(i) <- List.hd !r;
	    r := List.tl !r
	  done;
	  a

  let read_array read_cell lexbuf =
    let l = read_list_rev read_cell lexbuf in
    array_of_rev_list l
}
