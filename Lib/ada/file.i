/* -----------------------------------------------------------------------------
 * file.i
 *
 * The C 'FILE' type for Ada, which is opaque and used only by pointer.
 * ----------------------------------------------------------------------------- */

%{
#include <stdio.h>
%}

struct FILE;
