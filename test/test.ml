let () =
  Alcotest.run "Yojson" [
    "equality", Test_monomorphic.equality;
  ]
