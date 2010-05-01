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
    #ifdef INT
      try `Int (extract_positive_int lexbuf)
      with Int_overflow ->
    #endif
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
    #ifdef INT
      try `Int (extract_negative_int lexbuf)
      with Int_overflow ->
    #endif
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
  exception End_of_tuple
}

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

let ident = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '_' '0'-'9']*


rule read_json buf = parse
  | "true"      { `Bool true }
  | "false"     { `Bool false }
  | "null"      { `Null }
  | "NaN"       {
                  #ifdef FLOAT
                    `Float nan
                  #elif defined FLOATLIT
                    `Floatlit "NaN"
                  #endif
                }
  | "Infinity"  {
                  #ifdef FLOAT
                    `Float infinity
                  #elif defined FLOATLIT
                    `Floatlit "Infinity"
                  #endif
                }
  | "-Infinity" {
                  #ifdef FLOAT
                    `Float neg_infinity
                  #elif defined FLOATLIT
                    `Floatlit "-Infinity"
                  #endif
                }
  | '"'         {
                  #ifdef STRING
	            Buffer.clear buf;
		    `String (finish_string buf lexbuf)
                  #elif defined STRINGLIT
                    `Stringlit (finish_stringlit lexbuf)
                  #endif
                }
  | positive_int         { make_positive_int lexbuf }
  | '-' positive_int     { make_negative_int lexbuf }
  | float       {
                  #ifdef FLOAT
                    `Float (float_of_string (lexeme lexbuf))
                  #elif defined FLOATLIT
                    `Floatlit (lexeme lexbuf)
                  #endif
                 }

  | '{'          { let acc = ref [] in
		   try
		     read_space lexbuf;
		     let field_name = read_ident buf lexbuf in
		     read_space lexbuf;
		     read_colon lexbuf;
		     read_space lexbuf;
		     acc := (field_name, read_json buf lexbuf) :: !acc;
		     while true do
		       read_space lexbuf;
		       read_object_sep lexbuf;
		       read_space lexbuf;
		       let field_name = read_ident buf lexbuf in
		       read_space lexbuf;
		       read_colon lexbuf;
		       read_space lexbuf;
		       acc := (field_name, read_json buf lexbuf) :: !acc;
		     done;
		     assert false
		   with End_of_object ->
		     `Assoc (List.rev !acc)
		 }

  | '['          { let acc = ref [] in
		   try
		     read_space lexbuf;
		     acc := read_json buf lexbuf :: !acc;
		     while true do
		       read_space lexbuf;
		       read_array_sep lexbuf;
		       read_space lexbuf;
		       acc := read_json buf lexbuf :: !acc;
		     done;
		     assert false
		   with End_of_array ->
		     `List (List.rev !acc)
		 }

  | '('          {
                   #ifdef TUPLE
                     let acc = ref [] in
		     try
		       read_space lexbuf;
		       acc := read_json buf lexbuf :: !acc;
		       while true do
			 read_space lexbuf;
			 read_tuple_sep lexbuf;
			 read_space lexbuf;
			 acc := read_json buf lexbuf :: !acc;
		       done;
		       assert false
		     with End_of_tuple ->
		       `Tuple (List.rev !acc)
	           #else
		     lexer_error "Invalid token" lexbuf
                   #endif
		 }

  | '<'          {
                   #ifdef VARIANT
                     read_space lexbuf;
                     let cons = read_ident buf lexbuf in
		     read_space lexbuf;
		     `Variant (cons, finish_variant buf lexbuf)
                   #else
                     lexer_error "Invalid token" lexbuf
                   #endif
		 }

  | "//"[^'\n']* { read_json buf lexbuf }
  | "/*"         { finish_comment lexbuf; read_json buf lexbuf }
  | "\n"         { newline lexbuf; read_json buf lexbuf }
  | space        { read_json buf lexbuf }
  | eof          { raise End_of_file }
  | _            { lexer_error "Invalid token" lexbuf }


and finish_string buf = parse
    '"'           { Buffer.contents buf }
  | '\\'          { finish_escaped_char buf lexbuf;
		    finish_string buf lexbuf }
  | [^ '"' '\\']+ { add_lexeme buf lexbuf;
		    finish_string buf lexbuf }
  | eof           { custom_error "Unterminated string" lexbuf }

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


and finish_stringlit = parse
    ( '\\' (['"' '\\' '/' 'b' 'f' 'n' 'r' 't'] | 'u' hex hex hex hex)
    | [^'"' '\\'] )* '"'
         { let len = lexbuf.lex_curr_pos - lexbuf.lex_start_pos in
	   let s = String.create (len+1) in
	   s.[0] <- '"';
	   String.blit lexbuf.lex_buffer lexbuf.lex_start_pos s 1 len;
	   s
	 }

and finish_variant buf = parse 
    ':'  { let x = read_json buf lexbuf in
	   read_space lexbuf;
	   close_variant lexbuf;
	   Some x }
  | '>'  { None }

and close_variant = parse
    '>'  { () }

and finish_comment = parse
  | "*/" { () }
  | eof  { lexer_error "Unterminated comment" lexbuf }
  | '\n' { newline lexbuf; finish_comment lexbuf }
  | _    { finish_comment lexbuf }




(* Readers expecting a particular JSON construct *)

and read_space = parse
  | "//"[^'\n']*           { read_space lexbuf }
  | "/*"                   { finish_comment lexbuf; read_space lexbuf }
  | '\n'                   { newline lexbuf; read_space lexbuf }
  | [' ' '\t' '\r']+       { read_space lexbuf }
  | ""                     { () }

and read_null = parse
    "null"    { () }

and read_bool = parse
    "true"    { true }
  | "false"   { false }

and read_int = parse
    positive_int         { try extract_positive_int lexbuf
			   with Int_overflow ->
			     lexer_error "Int overflow" lexbuf }
  | '-' positive_int     { try extract_negative_int lexbuf
			   with Int_overflow ->
			     lexer_error "Int overflow" lexbuf }
  
and read_number = parse
  | "NaN"       { `Float nan }
  | "Infinity"  { `Float infinity }
  | "-Infinity" { `Float neg_infinity }
  | number      { `Float (float_of_string (lexeme lexbuf)) }

and read_string buf = parse
    '"'      { Buffer.clear buf;
	       finish_string buf lexbuf }

and read_ident buf = parse
    '"'      { Buffer.clear buf;
	       finish_string buf lexbuf }
  | ident as s
             { s }
  | '}'      { raise End_of_object }

and read_sequence read_cell init_acc = parse
    '['      { let acc = ref init_acc in
	       try
		 read_space lexbuf;
		 acc := read_cell !acc lexbuf;
		 while true do
		   read_space lexbuf;
		   read_array_sep lexbuf;
		   read_space lexbuf;
		   acc := read_cell !acc lexbuf;
		 done;
		 assert false
	       with End_of_array ->
		 !acc
	     }

and read_list_rev read_cell = parse
    '['      { let acc = ref [] in
	       try
		 read_space lexbuf;
		 acc := read_cell lexbuf :: !acc;
		 while true do
		   read_space lexbuf;
		   read_array_sep lexbuf;
		   read_space lexbuf;
		   acc := read_cell lexbuf :: !acc;
		 done;
		 assert false
	       with End_of_array ->
		 !acc
	     }

and read_array_sep = parse
    ','      { () }
  | ']'      { raise End_of_array }


and read_tuple read_cell init_acc = parse
    '('          {
                   #ifdef TUPLE
                     let pos = ref 0 in
                     let acc = ref init_acc in
		     try
		       read_space lexbuf;
		       acc := read_cell !pos !acc lexbuf;
		       incr pos;
		       while true do
			 read_space lexbuf;
			 read_tuple_sep lexbuf;
			 read_space lexbuf;
			 acc := read_cell !pos !acc lexbuf;
			 incr pos;
		       done;
		       assert false
		     with End_of_tuple ->
		       !acc
	           #else
		     lexer_error "Invalid token" lexbuf
                   #endif
		 }


and read_tuple_sep = parse
    ','      { () }
  | ')'      { raise End_of_tuple }

and read_fields read_field init_acc buf = parse
    '{'      { let acc = ref init_acc in
	       try
		 read_space lexbuf;
		 let field_name = read_ident buf lexbuf in
		 read_space lexbuf;
		 read_colon lexbuf;
		 read_space lexbuf;
		 acc := read_field !acc field_name lexbuf;
		 while true do
		   read_space lexbuf;
		   read_object_sep lexbuf;
		   read_space lexbuf;
		   let field_name = read_ident buf lexbuf in
		   read_space lexbuf;
		   read_colon lexbuf;
		   read_space lexbuf;
		   acc := read_field !acc field_name lexbuf;
		 done;
		 assert false
	       with End_of_object ->
		 !acc
	     }

and read_object_sep = parse
    ','      { () }
  | '}'      { raise End_of_object }

and read_colon = parse
    ':'      { () }

{
  let _ = (read_json : Buffer.t -> Lexing.lexbuf -> json)

  let read_list read_cell lexbuf =
    List.rev (read_list_rev read_cell lexbuf)

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

  let from_lexbuf ?buf lexbuf =
    let buf =
      match buf with
	  None -> Buffer.create 256
	| Some buf -> buf
    in
    read_json buf lexbuf

  let from_string ?buf s =
    from_lexbuf ?buf (Lexing.from_string s)

  let from_channel ?buf ic =
    from_lexbuf ?buf (Lexing.from_channel ic)

  let from_file ?buf file =
    let ic = open_in file in
    try
      let x = from_channel ?buf ic in
      close_in ic;
      x
    with e ->
      close_in_noerr ic;
      raise e
}
