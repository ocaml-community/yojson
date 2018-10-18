let pretty_format ?std (js : json) =
  let x = forget_positions js in
  Pretty.format ?std (x :> json_max)

let pretty_print ?std out (js : json) =
  Easy_format.Pretty.to_formatter out (pretty_format ?std js)

let pretty_to_string ?std (js : json) =
  let x = forget_positions js in
  Pretty.to_string ?std (x :> json_max)

let pretty_to_channel ?std oc (js : json) =
  let x = forget_positions js in
  Pretty.to_channel ?std oc (x :> json_max)
