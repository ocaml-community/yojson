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
    | NUMBER of string
    [@@deriving show]

