#ifndef __ada_adakw_swg__
#define __ada_adakw_swg__


// Warnings for Ada keywords


#define ADAKW(x) %namewarn("314:" #x " is a ada keyword") #x


ADAKW (abort);
ADAKW (abs);
ADAKW (abstract);
ADAKW (accept);
ADAKW (access);
ADAKW (aliased);
ADAKW (all);
ADAKW (and);
ADAKW (array);
ADAKW (at);
ADAKW (begin);
ADAKW (body);
ADAKW (case);
ADAKW (constant);
ADAKW (declare);
ADAKW (delay);
ADAKW (delta);
ADAKW (digits);
ADAKW (do);
ADAKW (else);
ADAKW (elsif);
ADAKW (end);
ADAKW (entry);
ADAKW (exception);
ADAKW (exit);
ADAKW (for);
ADAKW (function);
ADAKW (generic);
ADAKW (goto);
ADAKW (if);
ADAKW (in);
ADAKW (interface);
ADAKW (is);
ADAKW (limited);
ADAKW (loop);
ADAKW (mod);
ADAKW (new);
ADAKW (not);
ADAKW (null);
ADAKW (of);
ADAKW (or);
ADAKW (others);
ADAKW (out);
ADAKW (overriding);
ADAKW (package);
ADAKW (pragma);
ADAKW (private);
ADAKW (procedure);
ADAKW (protected);
ADAKW (raise);
ADAKW (range);
ADAKW (record);
ADAKW (rem);
ADAKW (renames);
ADAKW (requeue);
ADAKW (return);
ADAKW (reverse);
ADAKW (select);
ADAKW (separate);
ADAKW (subtype);
ADAKW (synchronized);
ADAKW (tagged);
ADAKW (task);
ADAKW (terminate);
ADAKW (then);
ADAKW (type);
ADAKW (until);
ADAKW (use);
ADAKW (when);
ADAKW (while);
ADAKW (with);
ADAKW (xor);


#undef ADAKW

#endif //__ada_adakw_swg__
