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

(* COMMENTS 7.4 *)
let line_terminator = [%sedlex.regexp? 0x000A | 0x000D | 0x2028 | 0x2029]
let source_character = [%sedlex.regexp? any]
let single_line_comment_char = [%sedlex.regexp? Sub (source_character, line_terminator)]
let single_line_comment = [%sedlex.regexp? "//", Star single_line_comment_char]
let multi_line_not_asterisk_char = [%sedlex.regexp? Sub (source_character, '*')]
let multi_line_not_slash_char = [%sedlex.regexp? Sub (source_character, '/')]
let multi_line_comment_char = [%sedlex.regexp? multi_line_not_asterisk_char | '*', Plus multi_line_not_slash_char]
let multi_line_comment = [%sedlex.regexp? "/*", Star multi_line_comment_char, Opt '*', "*/"]
let comment = [%sedlex.regexp? multi_line_comment | single_line_comment]

let white_space = [%sedlex.regexp? 0x0009 | 0x000B | 0x000C | 0x0020 | 0x00A0 | 0xFEFF | zs]

let rec lex tokens buf =
  let lexeme = Sedlexing.Utf8.lexeme in
  match%sedlex buf with
  | '{' -> lex (OPEN_BRACE::tokens) buf
  | '}' -> lex (CLOSE_BRACE::tokens) buf
  | '[' -> lex (OPEN_BRACKET::tokens) buf
  | ']' -> lex (CLOSE_BRACKET::tokens) buf
  | ':' -> lex (COLON::tokens) buf
  | ',' -> lex (COMMA::tokens) buf
  | comment
  | white_space
  | line_terminator -> lex tokens buf
  | "true" -> lex (TRUE::tokens) buf
  | "false" -> lex (FALSE::tokens) buf
  | "null" -> lex (NULL::tokens) buf
  | json5_float ->
    let s = float_of_string @@ lexeme buf in
    lex (FLOAT s::tokens) buf
  | json5_int_or_float ->
    let s = lexeme buf in 
    lex (INT_OR_FLOAT s::tokens) buf
  | json5_int ->
    let s = int_of_string @@ lexeme buf in 
    lex (INT s::tokens) buf
  | identifier_name ->
    let s = lexeme buf in 
    lex (IDENTIFIER_NAME s::tokens) buf
  | eof -> List.rev tokens
  | _ ->
    let s = lexeme buf in 
    failwith @@ "Unexpected character: '" ^ s ^ "'"
