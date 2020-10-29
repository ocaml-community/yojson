type token =
    | OPEN_BRACE
    | CLOSE_BRACE
    | OPEN_BRACKET
    | CLOSE_BRACKET
    | COLON
    | COMMA
    | TRUE
    | FALSE
    | NULL
    | SPACE
    | FLOAT of float
    | INT_OR_FLOAT of string
    | INT of int
    | IDENTIFIER_NAME of string
    [@@deriving show]

