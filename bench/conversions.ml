module SB = Core_bench_internals.Simplified_benchmark

let input_results in_chan =
  Sexplib.Sexp.input_sexp in_chan |> SB.Results.t_of_sexp

let metrics name value unit_name =
  `Assoc
    [
      ("name", `String name);
      ("value", `Float value);
      ("units", `String unit_name);
    ]

let extract full_name results =
  results
  |> List.map (fun (res : SB.Result.t) ->
         `Assoc
           [
             ( "results",
               `List
                 [
                   `Assoc
                     [
                       ("name", `String full_name);
                       ( "metrics",
                         `List
                           [
                             metrics
                               (res.full_benchmark_name ^ " (time)")
                               res.time_per_run_nanos "ns";
                             metrics
                               (res.full_benchmark_name ^ " (memory)/minor")
                               res.minor_words_per_run "words";
                             metrics
                               (res.full_benchmark_name ^ " (memory)/major")
                               res.major_words_per_run "words";
                           ] );
                     ];
                 ] );
           ])
  |> List.to_seq
  |> Yojson.Safe.seq_to_channel stdout

let () =
  let full_name = Sys.argv.(1) in
  input_results stdin |> extract full_name
