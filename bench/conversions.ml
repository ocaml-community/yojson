open Core_bench_internals.Simplified_benchmark

let input_results in_chan = Sexplib.Sexp.input_sexp in_chan |> Results.t_of_sexp

let extract full_name results =
  let open Result in
  List.iter
    (fun res ->
      Format.printf
        {|{"results": [{"name": "%s", "metrics": [{"name": "%s", "value": %f, "units": "%s"}]}]}@.|}
        full_name res.full_benchmark_name res.time_per_run_nanos "ns")
    results

let () =
  let full_name = Sys.argv.(1) in
  input_results stdin |> extract full_name
