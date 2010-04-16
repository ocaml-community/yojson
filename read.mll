(* $Id$ *)
{
  open Printf
  open Lexing

  let loc lexbuf = (lexbuf.lex_start_p, lexbuf.lex_curr_p)

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
    let len = stop - start in
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
        lexer_error "Int overflow"
      #endif

  let extract_negative_int lexbuf =
    let start = lexbuf.lex_start_pos + 1 in
    let stop = lexbuf.lex_curr_pos in
    let len = stop - start in
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
        lexer_error "Int overflow"
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
}

let space = [' ' '\t' '\r']+

let digit = ['0'-'9']
let nonzero = ['1'-'9']
let digits = digit+
let frac = '.' digits
let e = ['e' 'E']['+' '-']?
let exp = e digits

let positive_int = (digit | nonzero digits)
let float = int frac | int exp | int frac exp

let hex = [ '0'-'9' 'a'-'f' 'A'-'F' ]

let unescaped = ['\x20'-'\x21' '\x23'-'\x5B' '\x5D'-'\xFF' ]

rule read_json p = parse
  | "//"[^'\n']* { read_json p lexbuf }
  | "/*"         { finish_comment lexbuf; read_json p lexbuf }
  | '{'     { `Assoc (finish_assoc p lexbuf) }
  | '['     { `List (finish_list p lexbuf) }
  | "true"  { `Bool true }
  | "false" { `Bool false }
  | "null"  { `Null }
  | "NaN"   { `Float nan }
  | "Infinity"  { `Float infinity }
  | "-Infinity" { `Float neg_infinity }
  | '"'     { let buf = p.string_buf in
	      Buffer.clear buf;
	      `String (finish_string buf lexbuf) }
  | positive_int         { make_positive_int lexbuf }
  | '-' positive_int     { make_negative_int lexbuf }
  | float   { `Float (float_of_string (lexeme lexbuf)) }
  | "\n"    { newline lexbuf; read_json p lexbuf }
  | space   { read_json p lexbuf }
  | eof     { raise End_of_file }
  | _       { lexer_error "Invalid token" lexbuf }


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
         { utf8_of_bytes (hex a) (hex b) (hex c) (hex d) }
  | _    { lexer_error "Invalid escape sequence" lexbuf }

and finish_comment = parse
  | "*/" { () }
  | eof  { lexer_error "Unterminated comment" lexbuf }
  | '\n' { newline lexbuf; finish_comment lexbuf }
  | _    { finish_comment lexbuf }

{
  let make_param 
      ?(allow_comments = false)
      ?(allow_nan = false)
      ?(big_int_mode = false)
      () =
    { allow_comments = allow_comments;
      big_int_mode = big_int_mode;
      allow_nan = allow_nan }
}
