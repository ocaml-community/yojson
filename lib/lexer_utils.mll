rule read_junk buf n = parse
  | eof { () }
  | _ {
     if n <= 0 then ()
     else begin
       Buffer.add_char buf (Lexing.lexeme_char lexbuf 0);
       read_junk buf (n - 1) lexbuf
     end
     }
