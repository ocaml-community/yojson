
let pretty_print ?std out (x : t) =
  Pretty.pp ?std out (x :> json_max)

let pretty_to_string ?std (x : t) =
  Pretty.to_string ?std (x :> json_max)

let pretty_to_channel ?std oc (x : t) =
  Pretty.to_channel ?std oc (x :> json_max)
