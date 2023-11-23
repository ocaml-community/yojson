rule read_junk buf n = parse
  | eof { () }
  | _ {
     if n <= 0 then ()
     else begin
       Buffer.add_char buf (Lexing.lexeme_char lexbuf 0);
       read_junk buf (n - 1) lexbuf
     end
     }

{
let read_junk_without_positions buf n (lexbuf : Lexing.lexbuf) =
  let junk_start_pos = lexbuf.lex_start_pos in
  read_junk buf n lexbuf;
  lexbuf.lex_start_pos <- junk_start_pos + 1
}
