open Core_bench_internals.Simplified_benchmark

let input_results in_chan = Sexplib.Sexp.input_sexp in_chan |> Results.t_of_sexp

let metrics name value unit_name =
  let open Yojson.Safe in
  `Assoc
    [
      ("name", `String name);
      ("value", `Float value);
      ("units", `String unit_name);
    ]

let extract full_name results =
  let open Result in
  let open Yojson.Safe in
  List.iter
    (fun res ->
      let json =
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
                              res.minor_words_per_run
                              "words";
                            metrics
                              (res.full_benchmark_name ^ " (memory)/major")
                              res.major_words_per_run
                              "words";
                          ] );
                    ];
                ] );
          ]
      in
      to_channel stdout json;
      print_newline ())
    results

let () =
  let full_name = Sys.argv.(1) in
  input_results stdin |> extract full_name
