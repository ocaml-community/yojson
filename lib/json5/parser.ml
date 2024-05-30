open Let_syntax.Result

let rec parse_list acc = function
  | [] -> Error "List never ends"
  | Lexer.CLOSE_BRACKET :: xs -> Ok (acc, xs)
  | xs -> (
      let* v, xs = parse xs in
      match xs with
      | [] -> Error "List was not closed"
      | Lexer.CLOSE_BRACKET :: xs | COMMA :: CLOSE_BRACKET :: xs ->
          Ok (v :: acc, xs)
      | COMMA :: xs -> parse_list (v :: acc) xs
      | x :: _ ->
          let s =
            Format.asprintf "Unexpected list token: %a" Lexer.pp_token x
          in
          Error s)

and parse_assoc acc = function
  | [] -> Error "Assoc never ends"
  | Lexer.CLOSE_BRACE :: xs -> Ok (acc, xs)
  | STRING k :: COLON :: xs | IDENTIFIER_NAME k :: COLON :: xs -> (
      let* v, xs = parse xs in
      let item = (k, v) in
      match xs with
      | [] -> Error "Object was not closed"
      | Lexer.CLOSE_BRACE :: xs | COMMA :: CLOSE_BRACE :: xs ->
          Ok (item :: acc, xs)
      | COMMA :: xs -> parse_assoc (item :: acc) xs
      | x :: _ ->
          let s =
            Format.asprintf "Unexpected assoc list token: %a" Lexer.pp_token x
          in
          Error s)
  | x :: _ ->
      let s =
        Format.asprintf "Unexpected assoc list token: %a" Lexer.pp_token x
      in
      Error s

and parse = function
  | [] -> Error "empty list of tokens"
  | token :: xs -> (
      match token with
      | TRUE -> Ok (Ast.Bool true, xs)
      | FALSE -> Ok (Bool false, xs)
      | NULL -> Ok (Null, xs)
      | INT v -> Ok (IntLit v, xs)
      | FLOAT v -> Ok (FloatLit v, xs)
      | INT_OR_FLOAT v -> Ok (FloatLit v, xs)
      | STRING s -> Ok (StringLit s, xs)
      | OPEN_BRACKET ->
          let+ l, xs = parse_list [] xs in
          (Ast.List (List.rev l), xs)
      | OPEN_BRACE ->
          let+ a, xs = parse_assoc [] xs in
          (Ast.Assoc (List.rev a), xs)
      | x ->
          let s = Format.asprintf "Unexpected token: %a" Lexer.pp_token x in
          Error s)

let parse_from_lexbuf ?fname ?lnum lexbuffer =
  let fname = Option.value fname ~default:"" in
  Sedlexing.set_filename lexbuffer fname;
  let lnum = Option.value lnum ~default:1 in
  let pos =
    { Lexing.pos_fname = fname; pos_lnum = lnum; pos_bol = 0; pos_cnum = 0 }
  in
  Sedlexing.set_position lexbuffer pos;
  let* tokens = Lexer.lex [] lexbuffer in
  let+ ast, _unparsed = parse tokens in
  ast

let parse_from_string ?fname ?lnum input =
  parse_from_lexbuf (Sedlexing.Utf8.from_string input) ?fname ?lnum

let parse_from_channel ?fname ?lnum ic =
  parse_from_lexbuf (Sedlexing.Utf8.from_channel ic) ?fname ?lnum

let parse_from_file ?fname ?lnum filename =
  let ic = open_in filename in
  let out = parse_from_channel ?fname ?lnum ic in
  close_in ic;
  out
