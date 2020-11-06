open Types

let escape_string x = x

let rec parse_list acc = function
    | [] -> failwith "List never ends"
    | CLOSE_BRACKET::xs
    | COMMA::CLOSE_BRACKET::xs -> (acc, xs)
    | xs -> (
        let (v, xs) = parse xs in
        match xs with
        | [] -> failwith "List was not closed"
        | CLOSE_BRACKET::xs
        | COMMA::CLOSE_BRACKET::xs -> (v::acc, xs)
        | COMMA::xs -> parse_list (v::acc) xs
        | x::_ ->
            let s = Format.asprintf "Unexpected list token: %a" pp_token x in
            failwith s)
        
and parse_assoc acc = function
    | [] -> failwith "Assoc never ends"
    | CLOSE_BRACE::xs
    | COMMA::CLOSE_BRACE::xs -> (acc, xs)
    | (STRING k)::COLON::xs
    | (IDENTIFIER_NAME k)::COLON::xs -> (
        let (v, xs) = parse xs in
        let item = (k, v) in
        match xs with
        | [] -> failwith "Object was not closed"
        | CLOSE_BRACE::xs
        | COMMA::CLOSE_BRACE::xs -> (item::acc, xs)
        | COMMA::xs -> parse_assoc (item::acc) xs
        | x::_ ->
            let s = Format.asprintf "Unexpected assoc list token: %a" pp_token x in
            failwith s)
    | x::_ ->
        let s = Format.asprintf "Unexpected assoc list token: %a" pp_token x in
        failwith s

and parse : token list -> (t * token list) = function
    | [] -> failwith "empty list of tokens"
    | token::xs ->
        match token with
        | TRUE -> (`Bool true, xs)
        | FALSE -> (`Bool false, xs)
        | NULL -> (`Null, xs)
        | INT v -> (`Int v, xs)
        | FLOAT v -> (`Float v, xs)
        | INT_OR_FLOAT v -> (`String v, xs)
        | STRING s -> (`String (escape_string s), xs)
        | OPEN_BRACKET -> 
            let (l, xs) = parse_list [] xs in
            (`List (List.rev l), xs)
        | OPEN_BRACE ->
            let (a, xs) = parse_assoc [] xs in
            (`Assoc (List.rev a), xs)
        | x ->
            let s = Format.asprintf "Unexpected token: %a" pp_token x in
            failwith s



