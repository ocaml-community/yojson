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
let decimal_literal = (
    decimal_integer_literal '.' decimal_digits? exponent_part?
    | '.' decimal_digits exponent_part?
    | decimal_integer_literal exponent_part?
)
let hex_integer_literal = ( "0x" hex_digit+ | "0X" hex_digit+ )
let numeric_literal = ( decimal_literal | hex_integer_literal )
let json5_numeric_literal = ( numeric_literal | "Infinity" | "NaN" )
let json5_number = (json5_numeric_literal | '+' json5_numeric_literal | '-' json5_numeric_literal )

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
    | json5_number {
        let s = Lexing.lexeme lexbuf in 
        NUMBER s
    }
