/* Objects which can be moved and not copied: rvalue references, results and parameters which are moved, and 'std::unique_ptr'. */

%module moves

%include <swigmove.i>
%include <std_unique_ptr.i>

%{
#include "example.h"
int Buffer::alive = 0;
%}

%apply SWIGTYPE MOVE { Buffer b };     // A buffer which is passed by value is moved from the object of the caller.

%unique_ptr (Buffer);

class Buffer;                                         // The pointer has a member which points to a buffer, so the buffer is declared first,
%template (Buffer_owner) std::unique_ptr<Buffer>;     // and the pointer is named before the functions which use it.

%include "example.h"
