/* A record which does not match its structure. The wrapper file must not compile, which the launcher checks. */

%module wrong_layout

%{
#include "example.h"
%}

%include "example.h"
