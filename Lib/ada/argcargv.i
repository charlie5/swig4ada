/* -----------------------------------------------------------------------------
 * argcargv.i
 *
 * The typemaps of other languages turn a list of the language into the count
 * and array of strings which 'main' takes ('int ARGC, char **ARGV').
 *
 * Ada passes the two as they are: an 'int', and a pointer to the first of the
 * strings (an 'interfaces.C.Strings.chars_ptr_array' serves). So nothing is
 * needed here, and the file is given so that an interface which includes it
 * can be read.
 * ----------------------------------------------------------------------------- */
