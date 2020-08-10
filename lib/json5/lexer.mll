{
    open Types
}

rule read_token = parse
    | "{" { OPEN_BRACE }
    | "}" { CLOSE_BRACE }
    | "[" { OPEN_BRACKET }
    | "]" { CLOSE_BRACKET }
