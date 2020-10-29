open Types

(* From https://www.ecma-international.org/ecma-262/5.1/#sec-7 *)

(*
let digit = [%sedlex.regexp? '0'..'9']
let number = [%sedlex.regexp? Plus digit]
*)

(* NUMBERS, 7.8.3 *)
let non_zero_digit = [%sedlex.regexp? '1'..'9']
let decimal_digit = [%sedlex.regexp? '0'..'9']
let decimal_digits = [%sedlex.regexp? Plus decimal_digit]
let hex_digit = [%sedlex.regexp? '0'..'9'|'a'..'f'|'A'..'F']
let exponent_indicator = [%sedlex.regexp? 'e'|'E']
let signed_integer = [%sedlex.regexp? decimal_digits | '+', decimal_digits | '-', decimal_digits]
let exponent_part = [%sedlex.regexp? exponent_indicator, signed_integer]
let decimal_integer_literal = [%sedlex.regexp? '0' | non_zero_digit, Opt decimal_digits]
let hex_integer_literal = [%sedlex.regexp? "0x", Plus hex_digit | "0X", Plus hex_digit]
(* float *)
let float_literal = [%sedlex.regexp? decimal_integer_literal, '.', Opt decimal_digits, Opt exponent_part  | '.', decimal_digits, Opt exponent_part]
let json5_float = [%sedlex.regexp? float_literal | '+', float_literal | '-', float_literal]
(* int_or_float *)
let int_or_float_literal = [%sedlex.regexp? decimal_integer_literal, Opt exponent_part]
let json5_int_or_float = [%sedlex.regexp? int_or_float_literal | '+', int_or_float_literal | '-', int_or_float_literal]
(* int/hex *)
let json5_int = [%sedlex.regexp? hex_integer_literal | '+', hex_integer_literal | '-', hex_integer_literal]

(* IDENTIFIER_NAME (keys in objects) *)
let unicode_escape_sequence = [%sedlex.regexp? 'u', hex_digit, hex_digit, hex_digit, hex_digit]
let unicode_combining_mark =[%sedlex.regexp? mn | mc]
let unicode_digit = [%sedlex.regexp? nd]
let unicode_connector_punctuation = [%sedlex.regexp? pc]
let unicode_letter = [%sedlex.regexp? lu | ll | lt | lm | lo | nl]
let zwnj = [%sedlex.regexp? 0x200C]
let zwj = [%sedlex.regexp? 0x200D]
let identifier_start = [%sedlex.regexp? unicode_letter | '$' | '_' | '\\', unicode_escape_sequence]
let identifier_part = [%sedlex.regexp? identifier_start | unicode_combining_mark | unicode_digit | unicode_connector_punctuation | zwnj | zwj]
let identifier_name = [%sedlex.regexp? identifier_start, Star identifier_part]

let lex_next buf =
  let lexeme = Sedlexing.Utf8.lexeme in
  match%sedlex buf with
  | '{' -> OPEN_BRACE
  | '}' -> CLOSE_BRACE
  | '[' -> OPEN_BRACKET
  | ']' -> CLOSE_BRACKET
  | ':' -> COLON
  | ',' -> COMMA
  | ' ' -> SPACE
  | "true" -> TRUE
  | "false" -> FALSE
  | "null" -> NULL
  | json5_float ->
    let s = float_of_string @@ lexeme buf in
    FLOAT s
  | json5_int_or_float ->
      let s = lexeme buf in 
      INT_OR_FLOAT s
  | json5_int ->
      let s = int_of_string @@ lexeme buf in 
      INT s
  | identifier_name ->
      let s = lexeme buf in 
      IDENTIFIER_NAME s
  | eof -> EOF
  | _ ->
      let s = lexeme buf in 
      failwith @@ "Unexpected character: '" ^ s ^ "'"

let lex buf =
  let rec loop xs buf =
    match lex_next buf with
    | EOF -> xs
    | token -> loop (token::xs) buf
  in
  List.rev @@ loop [] buf
