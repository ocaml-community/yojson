open Types

let escape_string x = x

let rec parse_list acc = function
    | [] -> failwith "List never ends"
    | CLOSE_BRACKET::_ -> acc
    | x::COMMA::xs ->
        let acc = (parse [x])::acc in
        parse_list acc xs
    | x::CLOSE_BRACKET::_ ->
        (parse [x])::acc
    | x::_ ->
        let s = Format.asprintf "Unexpected list token: %a" pp_token x in
        failwith s
        
and parse_assoc acc = function
    | [] -> failwith "Assoc never ends"
    | CLOSE_BRACE::_ -> acc
    | (STRING k)::COLON::v::COMMA::xs
    | (IDENTIFIER_NAME k)::COLON::v::COMMA::xs ->
        let item = (k, parse [v]) in
        parse_assoc (item::acc) xs
    | (STRING k)::COLON::v::CLOSE_BRACE::_xs
    | (IDENTIFIER_NAME k)::COLON::v::CLOSE_BRACE::_xs ->
        (k, parse [v])::acc
    | x::_ ->
        let s = Format.asprintf "Unexpected assoc list token: %a" pp_token x in
        failwith s

and parse : token list -> t = function
    | [] -> failwith "empty list of tokens"
    | token::xs ->
        match token with
        | TRUE -> `Bool true
        | FALSE -> `Bool false
        | NULL -> `Null
        | INT v -> `Int v
        | FLOAT v -> `Float v
        | INT_OR_FLOAT v -> `String v
        | STRING s -> `String (escape_string s)
        | OPEN_BRACKET -> `List (parse_list [] xs)
        | OPEN_BRACE -> `Assoc (parse_assoc [] xs)
        | x ->
            let s = Format.asprintf "Unexpected token: %a" pp_token x in
            failwith s



