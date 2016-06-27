/* File : example.i */
%module simple_example

//extern int    gcd(int x, int y);
//extern double Foo;

%inline 
%{
  extern int    gcd(int x, int y);
  extern double Foo;
%}
