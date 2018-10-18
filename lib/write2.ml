let pretty_format ?std (x : json) =
#ifdef POSITION
  let x = forget_positions x in
#endif
  Pretty.format ?std (x :> json_max)

let pretty_print ?std out (x : json) =
  Easy_format.Pretty.to_formatter out (pretty_format ?std x)

let pretty_to_string ?std (x : json) =
#ifdef POSITION
  let x = forget_positions x in
#endif
  Pretty.to_string ?std (x :> json_max)

let pretty_to_channel ?std oc (x : json) =
#ifdef POSITION
  let x = forget_positions x in
#endif
  Pretty.to_channel ?std oc (x :> json_max)
