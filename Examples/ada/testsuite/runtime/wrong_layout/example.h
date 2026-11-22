/* A structure of which SWIG is not shown the whole: its record cannot have the layout of the structure. */

struct Sample
{
  int  first;
#ifndef SWIG
  char hidden [12];     // Not seen by SWIG, so not in the record.
#endif
  int  last;
};
