{
    open Types
}

(* From https://www.ecma-international.org/ecma-262/5.1/#sec-7 *)

(* NUMBERS, 7.8.3 *)
let non_zero_digit = ['1'-'9']
let decimal_digit = ['0'-'9']
let decimal_digits = decimal_digit+
let hex_digit = [ '0'-'9' 'a'-'f' 'A'-'F' ]
let exponent_indicator = ( 'e' | 'E' )
let signed_integer = ( decimal_digits | '+' decimal_digits | '-' decimal_digits )
let exponent_part = exponent_indicator signed_integer
let decimal_integer_literal = ( '0' | non_zero_digit decimal_digits? )
let hex_integer_literal = ( "0x" hex_digit+ | "0X" hex_digit+ )
(* float *)
let float_literal = ( decimal_integer_literal '.' decimal_digits? exponent_part?  | '.' decimal_digits exponent_part? )
let json5_float = ( float_literal | '+' float_literal | '-' float_literal )
(* int_or_float *)
let int_or_float_literal = decimal_integer_literal exponent_part?
let json5_int_or_float = ( int_or_float_literal | '+' int_or_float_literal | '-' int_or_float_literal )
(* int/hex *)
let json5_int = ( hex_integer_literal | '+' hex_integer_literal | '-' hex_integer_literal )

(* IDENTIFIER_NAME (keys in objects) *)
let unicode_escape_squence = 'u' hex_digit hex_digit hex_digit hex_digit
let unicode_letter = [ 'a'-'z' 'A'-'F' ]
let identifier_start = ( unicode_letter | '$' | '_' | '\\' unicode_escape_squence )
let identifier_part = ( identifier_start | decimal_digits ) (* unicode_combining_mark, unicode_connector_punctuation, ZWNJ and NWJ missing *)
let identifier_name = identifier_start identifier_part+?


(* STRINGS, 7.8.4 *)

rule read_token = parse
    | "{" { OPEN_BRACE }
    | "}" { CLOSE_BRACE }
    | "[" { OPEN_BRACKET }
    | "]" { CLOSE_BRACKET }
    | ":" { COLON }
    | "," { COMMA }
    | "true" { TRUE }
    | "false" { FALSE }
    | "null" { NULL }
    | " " { SPACE }
    | json5_float {
        let s = float_of_string @@ Lexing.lexeme lexbuf in 
        FLOAT s
    }
    | json5_int_or_float {
        let s = Lexing.lexeme lexbuf in 
        INT_OR_FLOAT s
    }
    | json5_int {
        let s = int_of_string @@ Lexing.lexeme lexbuf in 
        INT s
    }
    | identifier_name {
        let s = Lexing.lexeme lexbuf in 
        IDENTIFIER_NAME s
    }
