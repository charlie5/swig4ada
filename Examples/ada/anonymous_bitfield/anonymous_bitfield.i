%module anonymous_bitfield 

%constant   int   sizeof_unsigned_int = 8;

%inline %{

struct Foo {
   int x : 4;
   int y : 4;
   int   : 2;
   unsigned int f : 1;
   unsigned int : 5;
   int z : 15;
   unsigned int : 8+6; 
   unsigned seq : (sizeof(unsigned)*8 - 6); 
};

/* C fills the structure, reads it back, and gives its size, for the tester to compare with what Ada has. */

void fill (struct Foo* foo)
{
   foo->x   = -3;
   foo->y   = 5;
   foo->f   = 1;
   foo->z   = -1000;
   foo->seq = 123456;
}

long total (struct Foo* foo)
{
   return (long) foo->x + foo->y + foo->f + foo->z + foo->seq;
}

int size_of_Foo (void)
{
   return (int) sizeof (struct Foo);
}

%}

