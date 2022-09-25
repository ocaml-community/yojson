type token =
  | OPEN_PAREN
  | CLOSE_PAREN
  | OPEN_BRACE
  | CLOSE_BRACE
  | OPEN_BRACKET
  | CLOSE_BRACKET
  | COLON
  | COMMA
  | COMMENT of string
  | TRUE
  | FALSE
  | NULL
  | FLOAT of string
  | INT_OR_FLOAT of string
  | INT of string
  | STRING of string
  | IDENTIFIER_NAME of string

let pp_token ppf = function
  | OPEN_PAREN -> Format.fprintf ppf "'('"
  | CLOSE_PAREN -> Format.fprintf ppf "')'"
  | OPEN_BRACE -> Format.fprintf ppf "'{'"
  | CLOSE_BRACE -> Format.fprintf ppf "'}'"
  | OPEN_BRACKET -> Format.fprintf ppf "'['"
  | CLOSE_BRACKET -> Format.fprintf ppf "']'"
  | COLON -> Format.fprintf ppf "':'"
  | COMMA -> Format.fprintf ppf "','"
  | COMMENT s -> Format.fprintf ppf "COMMENT '%s'" s
  | TRUE -> Format.fprintf ppf "'true'"
  | FALSE -> Format.fprintf ppf "'false'"
  | NULL -> Format.fprintf ppf "'null'"
  | FLOAT s -> Format.fprintf ppf "FLOAT '%s'" s
  | INT_OR_FLOAT s -> Format.fprintf ppf "INT_OR_FLOAT '%s'" s
  | INT s -> Format.fprintf ppf "INT '%s'" s
  | STRING s -> Format.fprintf ppf "STRING '%s'" s
  | IDENTIFIER_NAME s -> Format.fprintf ppf "IDENTIFIER_NAME '%s'" s

let source_character = [%sedlex.regexp? any]
let line_terminator = [%sedlex.regexp? 0x000A | 0x000D | 0x2028 | 0x2029]

let line_terminator_sequence =
  [%sedlex.regexp? 0x000A | 0x000D, Opt 0x000A | 0x2028 | 0x2029]

(* NUMBERS, 7.8.3 *)
let non_zero_digit = [%sedlex.regexp? '1' .. '9']
let decimal_digit = [%sedlex.regexp? '0' .. '9']
let decimal_digits = [%sedlex.regexp? Plus decimal_digit]
let hex_digit = [%sedlex.regexp? '0' .. '9' | 'a' .. 'f' | 'A' .. 'F']
let exponent_indicator = [%sedlex.regexp? 'e' | 'E']

let signed_integer =
  [%sedlex.regexp? decimal_digits | '+', decimal_digits | '-', decimal_digits]

let exponent_part = [%sedlex.regexp? exponent_indicator, signed_integer]

let decimal_integer_literal =
  [%sedlex.regexp? '0' | non_zero_digit, Opt decimal_digits]

let hex_integer_literal =
  [%sedlex.regexp? "0x", Plus hex_digit | "0X", Plus hex_digit]

(* float *)
let float_literal =
  [%sedlex.regexp?
    ( decimal_integer_literal, '.', Opt decimal_digits, Opt exponent_part
    | '.', decimal_digits, Opt exponent_part )]

let json5_float =
  [%sedlex.regexp? float_literal | '+', float_literal | '-', float_literal]

(* int_or_float *)
let int_or_float_literal =
  [%sedlex.regexp? decimal_integer_literal, Opt exponent_part]

let json5_int_or_float =
  [%sedlex.regexp?
    int_or_float_literal | '+', int_or_float_literal | '-', int_or_float_literal]

(* int/hex *)
let int_literal =
  [%sedlex.regexp? decimal_digits | '+', decimal_digits | '-', decimal_digits]

let json5_int =
  [%sedlex.regexp?
    ( hex_integer_literal
    | '+', hex_integer_literal
    | '-', hex_integer_literal
    | int_literal )]

(* STRING LITERALS, 7.8.4 *)
let unicode_escape_sequence =
  [%sedlex.regexp? 'u', hex_digit, hex_digit, hex_digit, hex_digit]

let single_escape_character = [%sedlex.regexp? Chars {|'"\\bfnrtv|}]

let escape_character =
  [%sedlex.regexp? single_escape_character | decimal_digit | 'x' | 'u']

let non_escape_character =
  [%sedlex.regexp? Sub (source_character, (escape_character | line_terminator))]

let character_escape_sequence =
  [%sedlex.regexp? single_escape_character | non_escape_character]

let line_continuation = [%sedlex.regexp? '\\', line_terminator_sequence]

let escape_sequence =
  [%sedlex.regexp? character_escape_sequence | '0' | unicode_escape_sequence]

let single_string_character =
  [%sedlex.regexp?
    ( Sub (source_character, ('\'' | '\\' | line_terminator))
    | '\\', escape_sequence
    | line_continuation )]

let double_string_character =
  [%sedlex.regexp?
    ( Sub (source_character, ('"' | '\\' | line_terminator))
    | '\\', escape_sequence
    | line_continuation )]

let string_literal =
  [%sedlex.regexp?
    ( '"', Star double_string_character, '"'
    | '\'', Star single_string_character, '\'' )]

(* IDENTIFIER_NAME (keys in objects) *)
let unicode_combining_mark = [%sedlex.regexp? mn | mc]
let unicode_digit = [%sedlex.regexp? nd]
let unicode_connector_punctuation = [%sedlex.regexp? pc]
let unicode_letter = [%sedlex.regexp? lu | ll | lt | lm | lo | nl]
let zwnj = [%sedlex.regexp? 0x200C]
let zwj = [%sedlex.regexp? 0x200D]

let identifier_start =
  [%sedlex.regexp? unicode_letter | '$' | '_' | '\\', unicode_escape_sequence]

let identifier_part =
  [%sedlex.regexp?
    ( identifier_start | unicode_combining_mark | unicode_digit
    | unicode_connector_punctuation | zwnj | zwj )]

let identifier_name = [%sedlex.regexp? identifier_start, Star identifier_part]

(* COMMENTS 7.4 *)
let single_line_comment_char =
  [%sedlex.regexp? Sub (source_character, line_terminator)]

let single_line_comment = [%sedlex.regexp? "//", Star single_line_comment_char]
let multi_line_not_asterisk_char = [%sedlex.regexp? Sub (source_character, '*')]
let multi_line_not_slash_char = [%sedlex.regexp? Sub (source_character, '/')]

let multi_line_comment_char =
  [%sedlex.regexp?
    multi_line_not_asterisk_char | '*', Plus multi_line_not_slash_char]

let multi_line_comment =
  [%sedlex.regexp? "/*", Star multi_line_comment_char, Opt '*', "*/"]

let comment = [%sedlex.regexp? multi_line_comment | single_line_comment]

let white_space =
  [%sedlex.regexp? 0x0009 | 0x000B | 0x000C | 0x0020 | 0x00A0 | 0xFEFF | zs]

let rec lex : token list -> Sedlexing.lexbuf -> (token list, string) result =
 fun tokens buf ->
  let lexeme = Sedlexing.Utf8.lexeme in
  match%sedlex buf with
  | '(' -> lex (OPEN_PAREN :: tokens) buf
  | ')' -> lex (CLOSE_PAREN :: tokens) buf
  | '{' -> lex (OPEN_BRACE :: tokens) buf
  | '}' -> lex (CLOSE_BRACE :: tokens) buf
  | '[' -> lex (OPEN_BRACKET :: tokens) buf
  | ']' -> lex (CLOSE_BRACKET :: tokens) buf
  | ':' -> lex (COLON :: tokens) buf
  | ',' -> lex (COMMA :: tokens) buf
  | multi_line_comment | single_line_comment | white_space | line_terminator ->
      lex tokens buf
  | "true" -> lex (TRUE :: tokens) buf
  | "false" -> lex (FALSE :: tokens) buf
  | "null" -> lex (NULL :: tokens) buf
  | json5_float ->
      let s = lexeme buf in
      lex (FLOAT s :: tokens) buf
  | json5_int ->
      let s = lexeme buf in
      lex (INT s :: tokens) buf
  | json5_int_or_float ->
      let s = lexeme buf in
      lex (INT_OR_FLOAT s :: tokens) buf
  | identifier_name ->
      let s = lexeme buf in
      lex (IDENTIFIER_NAME s :: tokens) buf
  | string_literal ->
      let s = lexeme buf in
      lex (STRING s :: tokens) buf
  | eof -> Ok (List.rev tokens)
  | _ ->
      lexeme buf |> Format.asprintf "Unexpected character: '%s'" |> Result.error
