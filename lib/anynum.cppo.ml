module Basic : sig

#define INT
#define FLOAT
#define STRING

#include "type.ml"
#include "read.mli"

end = struct

#include "type.ml"
#include "write.ml"
module Pretty = struct
  #include "prettyprint.ml"
end

#include "write2.ml"
#include "read_anynum.ml"

#undef INT
#undef FLOAT
#undef STRING
end

module Raw : sig

#define INTLIT
#define FLOATLIT
#define STRINGLIT
#define TUPLE
#define VARIANT

#include "type.ml"
#include "read.mli"

end = struct

#include "type.ml"
#include "write.ml"
module Pretty = struct
  #include "prettyprint.ml"
end
#include "write2.ml"

#include "read_anynum.ml"

#undef INTLIT
#undef FLOATLIT
#undef STRINGLIT
#undef TUPLE
#undef VARIANT
end

module Safe : sig

#define INT
#define INTLIT
#define FLOAT
#define STRING
#define TUPLE
#define VARIANT

#include "type.ml"
#include "read.mli"

end  = struct

#include "type.ml"
#include "write.ml"
module Pretty = struct
  #include "prettyprint.ml"
end

#include "write2.ml"
#include "read_anynum.ml"

#undef INT
#undef INTLIT
#undef FLOAT
#undef STRING
#undef TUPLE
#undef VARIANT

end
