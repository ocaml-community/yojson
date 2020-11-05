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
    | FLOAT of float
    | INT_OR_FLOAT of string
    | INT of int
    | STRING of string
    | IDENTIFIER_NAME of string
    [@@deriving show, eq]

type t = Yojson.Safe.t
