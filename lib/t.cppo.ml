#define INTLIT

#include "type.ml"

#include "write.ml"

#include "monomorphic.ml"

module Pretty = struct
#include "prettyprint.ml"
end

#include "write2.ml"

#undef INTLIT
