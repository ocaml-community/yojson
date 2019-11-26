val pp : ?std:bool -> Format.formatter -> json -> unit
val to_string : ?std:bool -> json -> string
val to_channel : ?std:bool -> out_channel -> json -> unit
