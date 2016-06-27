
class Node
{

  public:

    Node ()   { State = 0; }

    Node (char*   file_Name)
    {
      //std::String   filename (file_Name);
      State = file_Name;
    }

    virtual
    ~Node()   { free (State); }


void
foo (char *    text) { State = text; }



//    virtual
//    void
//    dummy() {};


  private:

     char *     State;
};


/*
void
foo (char*  text) { printf ("text: '%s'", text); }
*/





/*
namespace osg {

class Vec2f;


class Vec2d
{
    public:


//        inline Vec2d(const Vec2f& vec) { _v[0]=vec._v[0]; _v[1]=vec._v[1]; }
//        inline Vec2d (const Vec2f& vec);
        Vec2d (const Vec2f& vec);
//        Vec2d (osg::Vec2f& vec);


};

}    // end of namespace osg
*/








// enum { num_components = 4 };




/*
namespace osg {

   typedef int   foo;

}
*/



//void setlocale (char *the_locale);

//char *setlocale (int __category, __const char *__locale);


/*
typedef struct  timespec {
	long		tv_nsec;
} timespec_t;



void foo (timespec*     xyz);
void bar (timespec_t*   xyz);
*/






/*
class wxWindowBase
{
public:

   wxWindowBase () {};
};




class wxLayoutConstraints //: public wxWindowBase
{
public:

    wxLayoutConstraints();

    // note that default copy ctor and assignment operators are ok

    virtual ~wxLayoutConstraints(){}

    wxWindowBase*  SatisfyConstraints (int *noChanges);
//    bool SatisfyConstraints(wxWindowBase *win, int *noChanges);

    // DECLARE_DYNAMIC_CLASS(wxLayoutConstraints)
};
*/



//typedef struct zfs_handle zfs_handle_t;




//#define XYZ  123l



//typedef enum {
//	ZFS_DELEG_USER = 'u'
//} zfs_deleg_who_type_t;




//#define	MAX_INPUT	512



//#define SWITCH_SEQ_HOME_CHAR 'H'




//typedef struct switch_media_bug switch_media_bug_t;
//
//struct switch_media_bug;



/*
struct switch_directories {
	char *base_dir;
};

typedef struct switch_directories switch_directories;

int
moo (struct switch_directories   p1);
*/




//   typedef unsigned short**   kungfoo;






/*
typedef void*   vpointer;



struct entity_t
  {
  double	fitness;
  vpointer	*chromosome;
  vpointer	data;
  };



typedef struct entity_t entity;


//typedef struct population_t population;

*/



/*
#define SCARD_CLASS_VENDOR_INFO   5

#define SCARD_ATTR_VALUE(Class, Tag) ((((ULONG)(Class)) << 16) | ((ULONG)(Tag)))


#define SCARD_ATTR_VENDOR_NAME SCARD_ATTR_VALUE(SCARD_CLASS_VENDOR_INFO, 0x0100)
*/




/*
typedef struct ss {
    char*     Gloss;
} Synset;
*/




/*
typedef struct ss {
    int id;
    struct ss *nextss;
} Synset;


typedef Synset *SynsetPtr;
*/



//extern int (*display_message)(char *);










//#define	ZFS_CRC64_POLY	0xC96C5795D7870F42ULL





/*
typedef struct unicase_info_st
{
  int toupper;
  int tolower;
  int sort;
} MY_UNICASE_INFO;


extern MY_UNICASE_INFO *my_unicase_default[256];
*/





//#define INT_MIN32       (~0x7FFFFFFFL)
//#define UINT_MAX32      0xFFFFFFFFUL



/*
#define MACHINE_TYPE "i486"

const char*   Name = "billyBoy";
*/



//#include <stdio.h>


//void fooey (int  lll) { printf ("\nfooey: %d\n", lll); }





/*
class Outer {
public:
  class Inner {
    public:
      int var;
      Inner(int v = 0) : var(v) {}
  };
  void method(Inner inner);

  Inner   kkk;
};
*/



/*
#include <vector>

void   fook (std::vector<int>  ages);
*/



/*
namespace globals
{
  const double iceBounciness = (double)0.05;
};
*/

//void blip (const float&   x);



//extern char tzname[5];
//extern char* tzname[];
//extern float* tzname[];




//#define DEC_Conversion_syntax    0x00000001




/*
class xyz
{
   int my_int;
};



//enum xyz {red, green};

//typedef xyz     lmn;

typedef int   fff [sizeof(xyz)];
*/




//typedef void dMessageFunction (int errnum, const char *msg, va_list ap);

//void dSetErrorHandler (dMessageFunction *fn);

/*
#undef __cplusplus

#ifdef __cplusplus
extern "C" {
#endif

typedef void * dAllocFunction (size_t size);
//typedef void * dReallocFunction (void *ptr, size_t oldsize, size_t newsize);
//typedef void dFreeFunction (void *ptr, size_t size);

//void dSetAllocHandler (dAllocFunction *fn);
//void dSetReallocHandler (dReallocFunction *fn);
//void dSetFreeHandler (dFreeFunction *fn);

//dAllocFunction *dGetAllocHandler (void);
//dReallocFunction *dGetReallocHandler (void);
//dFreeFunction *dGetFreeHandler (void);

//void * dAlloc (size_t size);
//void * dRealloc (void *ptr, size_t oldsize, size_t newsize);
//void dFree (void *ptr, size_t size);

#ifdef __cplusplus
}
#endif
*/


/*
class ppp
{
public:

typedef int __io_close_fn (void *__cookie);


void kkk (__io_close_fn*  lll);
};
*/



//extern int kkk [5];

//typedef char*  zzz [5];

//extern zzz    yyy;

//extern int    jjj [9];

//extern char*  kkk [7];






//#define _IO_MAGIC 0xFBAD0000 /* Magic number */






/*
# define k_SIGSET_NWORDS	(1024 / (8 * sizeof (unsigned long int)))
//# define k_SIGSET_NWORDS	(5 + (1 + 2))
 //(1024 / (8 * sizeof (unsigned long int)))

typedef struct
  {
    unsigned long int k__val [k_SIGSET_NWORDS];
  } k__sigset_t;



# define _SIGSET_NWORDS	(1024 / (8 * sizeof (unsigned long int)))
typedef struct
  {
    unsigned long int __val[_SIGSET_NWORDS];
  } __sigset_t;

*/



//#include <time.h>

//void         g_date_set_time_t            (time_t       timet);

//typedef unsigned long int my__u_quad_t;

//typedef long long unsigned int   kkk;


/*
  struct mpn {
    int mantissa_low : 32;
    int mantissa_high : 20;
    int biased_exponent : 11;
    int sign : 1;
  };
*/



/*
typedef union  _GDoubleIEEE754	GDoubleIEEE754;

union _GDoubleIEEE754
{
  double v_double;
  struct {
    int mantissa_low : 32;
    int mantissa_high : 20;
    int biased_exponent : 11;
    int sign : 1;
  } mpn;
};
*/


/*
union _GDoubleIEEE754
{
  gdouble v_double;
  struct {
    guint sign : 1;
    guint biased_exponent : 11;
    guint mantissa_high : 20;
    guint mantissa_low : 32;
  } mpn;
};
*/

/*
typedef struct _GtsGEdge         GtsGEdge;
//typedef struct _GtsGEdgeClass    GtsGEdgeClass;

struct _GtsGEdge {
//  GtsContainee containee;

//  GtsGNode * n1;
//  GtsGNode * n2;
};

struct _GtsGEdgeClass {
//  GtsContaineeClass parent_class;

  GtsGEdge * (* link)   (void);
//  GtsGEdge * (* link)   (GtsGEdge * e, GtsGNode * n1, GtsGNode * n2);

//  gfloat     (* weight) (GtsGEdge * e);
//  void       (* write)  (GtsGEdge * e, FILE * fp);
};
*/






/*
#include "foo.h"


//enum zoink { NamedAnon1, NamedAnon2 };


//typedef int   kInt;
//enum xyz {e1, e2};
class xyz {};


//void floogle (gint   my_arg);
void floogle (xyz*   my_arg);

void waggle (hair*   my_hair);
*/



/*
  // namespaces
  namespace AType {
    //enum AType { NoType };
  }

//  void dummy(AType::AType aType = AType::NoType) {}



namespace Space {
struct Klass {
  //int val;
  //Klass(int val = -1) : val(val) {}

  //~Klass() {};

};

//Klass constructorcall(const Klass& k = Klass()) { return k; }

}
*/




















/*
namespace Space {
struct Klass {
  int val;
  Klass(int val = -1) : val(val) {}

  ~Klass() {};

};
Klass constructorcall(const Klass& k = Klass()) { return k; }

}
*/





/*
#define OTHERLAND_MSG "Little message from the the safe world."
#define CPLUSPLUS_MSG "A message from the deep dark world of C++, where anything is possible."

static char *global_str = NULL;
const int UINT_DIGITS = 10; // max unsigned int is 4294967295


bool
check (const char *   str,
       unsigned int   number)
{
  static char expected[256];
  sprintf(expected, "%s%d", OTHERLAND_MSG, number);
  bool matches = (strcmp(str, expected) == 0);
  if (!matches) printf("Failed: [%s][%s]\n", str, expected);
  return matches;
}



  char *
  GetNewCharString()
  {
    char *nstr = new char[sizeof(CPLUSPLUS_MSG)+1];
    strcpy(nstr, CPLUSPLUS_MSG);
    return nstr;
  }

*/


  //struct Formatpos;
  //struct OBFormat;

  //typedef OBFormat*   swig_p_OBFormat;    //tbd(gnat):had to add this as workaround. 'swig_p_OBFormat' is not generated since it is not
  //                                        //          directly referred to (only a reference to it is given)

//  static
//  int
//  GetNextFormat(Formatpos& itr, const  char*& str,OBFormat*& pFormat)
//  {
//    return 0;
//  }











/*
enum old_name { argh, eek = -1 };
*/



//enum { AnonEnum3, AnonEnum4 } instance;


//namespace AnonSpace{
//  typedef enum { NamedAnonSpace1, NamedAnonSpace2 }; // namedanonspace;
//  namedanonspace                namedanonspaceTest1(namedanonspace e) { return e; }
//  AnonSpace::namedanonspace     namedanonspaceTest2(AnonSpace::namedanonspace e) { return e; }
//}

//AnonSpace::namedanonspace       namedanonspaceTest3(AnonSpace::namedanonspace e) { return e; }

//using namespace AnonSpace;
//namedanonspace                  namedanonspaceTest4(namedanonspace e) { return e; }





/*
typedef enum twonamestag { TwoNames1, TwoNames2, TwoNames3 = 33 } twonames;

//twonames                        twonamesTest1(twonames e) { return e; }
//twonamestag                     twonamesTest2(twonamestag e) { return e; }
//enum twonamestag                twonamesTest3(enum twonamestag e) { return e; }
*/



/*
template<typename T> struct TemplateClass {
  enum scientists { einstein, galileo = 10 };
};



TemplateClass<int>::scientists              scientistsTest1(TemplateClass<int>::scientists e) { return e; }
*/




/*
namespace Name {
template<typename T> struct TClass {
  enum scientists { faraday, bell = 20 };
  typedef enum scientists scientiststd1;
//  typedef scientists scientiststd2;
//  typedef scientiststd1 scientiststd3;

  scientists                                scientistsNameTest1(scientists e) { return e; }
  enum scientists                           scientistsNameTest2(enum scientists e) { return e; }
  const scientists                          scientistsNameTest3(const scientists e) { return e; }
  const enum scientists                     scientistsNameTest4(const enum scientists e) { return e; }
  typename TClass<T>::scientists            scientistsNameTest5(typename TClass<T>::scientists e) { return e; }
  const typename TClass<T>::scientists      scientistsNameTest6(const typename TClass<T>::scientists e) { return e; }
  enum TClass<T>::scientists                scientistsNameTest7(enum TClass<T>::scientists e) { return e; }
  const enum TClass<T>::scientists          scientistsNameTest8(const enum TClass<T>::scientists e) { return e; }
  typename TClass::scientists               scientistsNameTest9(typename TClass::scientists e) { return e; }
//  enum TClass::scientists                   scientistsNameTestA(enum TClass::scientists e) { return e; }
  const typename TClass::scientists         scientistsNameTestB(const typename TClass::scientists e) { return e; }
//  const enum TClass::scientists             scientistsNameTestC(const enum TClass::scientists e) { return e; }
  scientiststd1                             scientistsNameTestD(scientiststd1 e) { return e; }
  scientiststd2                             scientistsNameTestE(scientiststd2 e) { return e; }
  scientiststd3                             scientistsNameTestF(scientiststd3 e) { return e; }
  typename TClass<T>::scientiststd1         scientistsNameTestG(typename TClass<T>::scientiststd1 e) { return e; }
  typename TClass<T>::scientiststd2         scientistsNameTestH(typename TClass<T>::scientiststd2 e) { return e; }
  typename TClass<T>::scientiststd3         scientistsNameTestI(typename TClass<T>::scientiststd3 e) { return e; }

  typename Name::TClass<T>::scientists      scientistsNameSpaceTest1(typename Name::TClass<T>::scientists e) { return e; }
  const typename Name::TClass<T>::scientists         scientistsNameSpaceTest2(const typename Name::TClass<T>::scientists e) { return e; }
  enum Name::TClass<T>::scientists          scientistsNameSpaceTest3(enum Name::TClass<T>::scientists e) { return e; }
  const enum Name::TClass<T>::scientists    scientistsNameSpaceTest4(const enum Name::TClass<T>::scientists e) { return e; }
  typename Name::TClass<T>::scientiststd1   scientistsNameSpaceTest5(typename Name::TClass<T>::scientiststd1 e) { return e; }
  typename Name::TClass<T>::scientiststd2   scientistsNameSpaceTest6(typename Name::TClass<T>::scientiststd2 e) { return e; }
  typename Name::TClass<T>::scientiststd3   scientistsNameSpaceTest7(typename Name::TClass<T>::scientiststd3 e) { return e; }

  // Test TemplateClass::scientists rather then TClass::scientists
  ::TemplateClass<int>::scientists              scientistsOtherTest1(::TemplateClass<int>::scientists e) { return e; }
  const ::TemplateClass<int>::scientists        scientistsOtherTest2(const ::TemplateClass<int>::scientists e) { return e; }
  enum ::TemplateClass<int>::scientists         scientistsOtherTest3(enum ::TemplateClass<int>::scientists e) { return e; }
  const enum ::TemplateClass<int>::scientists   scientistsOtherTest4(const enum ::TemplateClass<int>::scientists e) { return e; }
  ::TemplateClass<int>::scientiststd1           scientistsOtherTest5(::TemplateClass<int>::scientiststd1 e) { return e; }
  ::TemplateClass<int>::scientiststd2           scientistsOtherTest6(::TemplateClass<int>::scientiststd2 e) { return e; }
  ::TemplateClass<int>::scientiststd3           scientistsOtherTest7(::TemplateClass<int>::scientiststd3 e) { return e; }

};
*/
/*
TClass<int>::scientists                     scientistsNameTest1(TClass<int>::scientists e) { return e; }
const TClass<int>::scientists               scientistsNameTest2(const TClass<int>::scientists e) { return e; }
enum TClass<int>::scientists                scientistsNameTest3(enum TClass<int>::scientists e) { return e; }
const enum TClass<int>::scientists          scientistsNameTest4(const enum TClass<int>::scientists e) { return e; }
TClass<int>::scientiststd1                  scientistsNameTest5(TClass<int>::scientiststd1 e) { return e; }
TClass<int>::scientiststd2                  scientistsNameTest6(TClass<int>::scientiststd2 e) { return e; }
TClass<int>::scientiststd3                  scientistsNameTest7(TClass<int>::scientiststd3 e) { return e; }

Name::TClass<int>::scientists               scientistsNameSpaceTest1(Name::TClass<int>::scientists e) { return e; }
const Name::TClass<int>::scientists         scientistsNameSpaceTest2(const Name::TClass<int>::scientists e) { return e; }
enum Name::TClass<int>::scientists          scientistsNameSpaceTest3(enum Name::TClass<int>::scientists e) { return e; }
const enum Name::TClass<int>::scientists    scientistsNameSpaceTest4(const enum Name::TClass<int>::scientists e) { return e; }
Name::TClass<int>::scientiststd1            scientistsNameSpaceTest5(Name::TClass<int>::scientiststd1 e) { return e; }
Name::TClass<int>::scientiststd2            scientistsNameSpaceTest6(Name::TClass<int>::scientiststd2 e) { return e; }
Name::TClass<int>::scientiststd3            scientistsNameSpaceTest7(Name::TClass<int>::scientiststd3 e) { return e; }

}
*/

/*
Name::TClass<int>::scientists               scientistsNameSpaceTest8(Name::TClass<int>::scientists e) { return e; }
const Name::TClass<int>::scientists         scientistsNameSpaceTest9(const Name::TClass<int>::scientists e) { return e; }
enum Name::TClass<int>::scientists          scientistsNameSpaceTestA(enum Name::TClass<int>::scientists e) { return e; }
const enum Name::TClass<int>::scientists    scientistsNameSpaceTestB(const enum Name::TClass<int>::scientists e) { return e; }
Name::TClass<int>::scientiststd1            scientistsNameSpaceTestC(Name::TClass<int>::scientiststd1 e) { return e; }
Name::TClass<int>::scientiststd2            scientistsNameSpaceTestD(Name::TClass<int>::scientiststd2 e) { return e; }
Name::TClass<int>::scientiststd3            scientistsNameSpaceTestE(Name::TClass<int>::scientiststd3 e) { return e; }

using namespace Name;
TClass<int>::scientists                     scientistsNameSpaceTestF(TClass<int>::scientists e) { return e; }
const TClass<int>::scientists               scientistsNameSpaceTestG(const TClass<int>::scientists e) { return e; }
enum TClass<int>::scientists                scientistsNameSpaceTestH(enum TClass<int>::scientists e) { return e; }
const enum TClass<int>::scientists          scientistsNameSpaceTestI(const enum TClass<int>::scientists e) { return e; }
TClass<int>::scientiststd1                  scientistsNameSpaceTestJ(TClass<int>::scientiststd1 e) { return e; }
TClass<int>::scientiststd2                  scientistsNameSpaceTestK(TClass<int>::scientiststd2 e) { return e; }
TClass<int>::scientiststd3                  scientistsNameSpaceTestL(TClass<int>::scientiststd3 e) { return e; }
*/



/*
struct TreesClass {
  enum trees {oak, fir, pine };
};


typedef enum TreesClass::trees treesglobaltd1;
*/




/*
treesglobaltd1                      treesTestD(treesglobaltd1 e) { return e; }
treesglobaltd2                      treesTestE(treesglobaltd2 e) { return e; }
treesglobaltd3                      treesTestF(treesglobaltd3 e) { return e; }
treesglobaltd4                      treesTestG(treesglobaltd4 e) { return e; }
treesglobaltd5                      treesTestH(treesglobaltd5 e) { return e; }
const treesglobaltd1                treesTestI(const treesglobaltd1 e) { return e; }
const treesglobaltd2                treesTestJ(const treesglobaltd2 e) { return e; }
const treesglobaltd3                treesTestK(const treesglobaltd3 e) { return e; }
const treesglobaltd4                treesTestL(const treesglobaltd4 e) { return e; }
const treesglobaltd5                treesTestM(const treesglobaltd5 e) { return e; }

typedef const enum TreesClass::trees treesglobaltd6;
typedef const TreesClass::trees treesglobaltd7;
typedef const TreesClass::treestd1 treesglobaltd8;
typedef const TreesClass::treestd2 treesglobaltd9;
typedef const treesglobaltd4 treesglobaltdA;

treesglobaltd6                      treesTestN(treesglobaltd6 e) { return e; }
treesglobaltd7                      treesTestO(treesglobaltd7 e) { return e; }
treesglobaltd8                      treesTestP(treesglobaltd8 e) { return e; }
treesglobaltd9                      treesTestQ(treesglobaltd9 e) { return e; }
treesglobaltdA                      treesTestR(treesglobaltdA e) { return e; }
*/







/*
namespace AnonSpace{

  typedef enum { NamedAnonSpace1, NamedAnonSpace2 } namedanonspace;

  namedanonspace                namedanonspaceTest1(namedanonspace e) { return e; }
  AnonSpace::namedanonspace     namedanonspaceTest2(AnonSpace::namedanonspace e) { return e; }
}

AnonSpace::namedanonspace       namedanonspaceTest3(AnonSpace::namedanonspace e) { return e; }

using namespace AnonSpace;
namedanonspace                  namedanonspaceTest4(namedanonspace e) { return e; }
*/





//typedef struct MemChunk_t MemChunk;




/*
#define RANDOM_NUM_STATE_VALS	57


typedef struct random_state_t
  {
  unsigned int	v[RANDOM_NUM_STATE_VALS];
  int		j, k, x;
  } random_state;


void  mumble (unsigned my_arg[5]);



//  #define NULL_CHAR	('\0')     tbd: !!!



typedef struct dStopwatch {
  double time;
  unsigned long cc[2];
} dStopwatch;
*/



/*
typedef void * (*dAllocFunction_ptr) (size_t size);

void dSetAllocHandler (dAllocFunction_ptr fn);
*/



/*
template<typename T> struct TemplateClass {

  enum scientists { einstein, galileo = 10 };
  typedef enum scientists scientiststd1;

};

//void                                      scientistsTest1(TemplateClass<int>::scientists    e) { ; }
//TemplateClass<int>::scientists              scientistsTest1(TemplateClass<int>::scientists e) { return e; }
//const TemplateClass<int>::scientists        scientistsTest2(const TemplateClass<int>::scientists e) { return e; }
//enum TemplateClass<int>::scientists         scientistsTest3(enum TemplateClass<int>::scientists e) { return e; }
//const enum TemplateClass<int>::scientists   scientistsTest4(const enum TemplateClass<int>::scientists e) { return e; }
TemplateClass<int>::scientiststd1           scientistsTest5(TemplateClass<int>::scientiststd1 e) { return e; }
//TemplateClass<int>::scientiststd2           scientistsTest6(TemplateClass<int>::scientiststd2 e) { return e; }
//TemplateClass<int>::scientiststd3           scientistsTest7(TemplateClass<int>::scientiststd3 e) { return e; }
//const TemplateClass<int>::scientiststd3 &   scientistsTest8(const TemplateClass<int>::scientiststd3 &e) { return e; }
*/


/*
namespace Name {

template<typename T> struct TClass {

  enum scientists { faraday, bell = 20 };
  typedef enum scientists scientiststd1;
};

}
*/





/*
template<typename T> struct TemplateClass {
  enum scientists { einstein, galileo = 10 };

  typedef enum scientists scientiststd1;
  typedef scientists scientiststd2;
  typedef scientiststd1 scientiststd3;
  scientists                                scientistsTest1(scientists e) { return e; }
  enum scientists                           scientistsTest2(enum scientists e) { return e; }
  const scientists                          scientistsTest3(const scientists e) { return e; }
  const enum scientists                     scientistsTest4(const enum scientists e) { return e; }
  typename TemplateClass<T>::scientists     scientistsTest5(typename TemplateClass<T>::scientists e) { return e; }
  const typename TemplateClass<T>::scientists        scientistsTest6(const typename TemplateClass<T>::scientists e) { return e; }
  enum TemplateClass<T>::scientists         scientistsTest7(enum TemplateClass<T>::scientists e) { return e; }
  const enum TemplateClass<T>::scientists   scientistsTest8(const enum TemplateClass<T>::scientists e) { return e; }
  typename TemplateClass::scientists        scientistsTest9(typename TemplateClass::scientists e) { return e; }


//  enum TemplateClass::scientists            scientistsTestA(enum TemplateClass::scientists e) { return e; }


  const typename TemplateClass::scientists  scientistsTestB(const typename TemplateClass::scientists e) { return e; }
//  const enum TemplateClass::scientists      scientistsTestC(const enum TemplateClass::scientists e) { return e; }
  scientiststd1                             scientistsTestD(scientiststd1 e) { return e; }
  scientiststd2                             scientistsTestE(scientiststd2 e) { return e; }
  scientiststd3                             scientistsTestF(scientiststd3 e) { return e; }
  typename TemplateClass<T>::scientiststd1  scientistsTestG(typename TemplateClass<T>::scientiststd1 e) { return e; }
  typename TemplateClass<T>::scientiststd2  scientistsTestH(typename TemplateClass<T>::scientiststd2 e) { return e; }
  typename TemplateClass<T>::scientiststd3  scientistsTestI(typename TemplateClass<T>::scientiststd3 e) { return e; }
  const scientists &                        scientistsTestJ(const scientists &e) { return e; }

};
*/






//dsfgdfgfffffffffffffffffffff
/*
template<typename T> struct TemplateClass {
  enum scientists { einstein, galileo = 10 };
  typedef enum scientists scientiststd1;
};


TemplateClass<int>::scientiststd1           scientistsTest5(TemplateClass<int>::scientiststd1 e) { return e; }


namespace Name {

}
*/









/*
Name::TClass<int>::scientists               scientistsNameSpaceTest8(Name::TClass<int>::scientists e) { return e; }
const Name::TClass<int>::scientists         scientistsNameSpaceTest9(const Name::TClass<int>::scientists e) { return e; }
enum Name::TClass<int>::scientists          scientistsNameSpaceTestA(enum Name::TClass<int>::scientists e) { return e; }
const enum Name::TClass<int>::scientists    scientistsNameSpaceTestB(const enum Name::TClass<int>::scientists e) { return e; }
Name::TClass<int>::scientiststd1            scientistsNameSpaceTestC(Name::TClass<int>::scientiststd1 e) { return e; }
Name::TClass<int>::scientiststd2            scientistsNameSpaceTestD(Name::TClass<int>::scientiststd2 e) { return e; }
Name::TClass<int>::scientiststd3            scientistsNameSpaceTestE(Name::TClass<int>::scientiststd3 e) { return e; }

using namespace Name;
TClass<int>::scientists                     scientistsNameSpaceTestF(TClass<int>::scientists e) { return e; }
const TClass<int>::scientists               scientistsNameSpaceTestG(const TClass<int>::scientists e) { return e; }
enum TClass<int>::scientists                scientistsNameSpaceTestH(enum TClass<int>::scientists e) { return e; }
const enum TClass<int>::scientists          scientistsNameSpaceTestI(const enum TClass<int>::scientists e) { return e; }
TClass<int>::scientiststd1                  scientistsNameSpaceTestJ(TClass<int>::scientiststd1 e) { return e; }
TClass<int>::scientiststd2                  scientistsNameSpaceTestK(TClass<int>::scientiststd2 e) { return e; }
TClass<int>::scientiststd3                  scientistsNameSpaceTestL(TClass<int>::scientiststd3 e) { return e; }
*/





//enum { AnonEnum3, AnonEnum4 } instance;


/*
typedef enum { NamedAnon1, NamedAnon2 } namedanon;

namedanon                       namedanonTest1(namedanon e) { return e; }





typedef enum twonamestag { TwoNames1, TwoNames2, TwoNames3 = 33 } twonames;
//enum twonamestag { TwoNames1, TwoNames2, TwoNames3 = 33 };
//typedef enum twonamestag  kkk;

twonames                        twonamesTest1(twonames e) { return e; }
twonamestag                     twonamesTest2(twonamestag e) { return e; }
enum twonamestag                twonamesTest3(enum twonamestag e) { return e; }

struct TwoNamesStruct {
  typedef enum twonamestag { TwoNamesStruct1, TwoNamesStruct2 } twonames;
  twonames                      twonamesTest1(twonames e) { return e; }
  twonamestag                   twonamesTest2(twonamestag e) { return e; }
  enum twonamestag              twonamesTest3(enum twonamestag e) { return e; }
};




enum old_name { argh, eek = -1 };
*/














/*
namespace RepeatSpace {

//#define last   9

typedef enum
{
   one = 1,
   initial = one,
   two,
   three,
   last = three,
   end = last
} repeat;

repeat repeatTest(repeat e) { return e; }

}
*/





/*
    typedef struct Pointf {
      double		x,y;
    } Pointf;


Pointf
glog (Pointf an_arg);
*/





/*
typedef enum twonamestag { TwoNames1, TwoNames2, TwoNames3 = 33 } twonames;

twonames                        twonamesTest1(twonames e) { return e; }
twonamestag                     twonamesTest2(twonamestag e) { return e; }
enum twonamestag                twonamesTest3(enum twonamestag e) { return e; }


struct TwoNamesStruct {
  typedef enum twonamestag { TwoNamesStruct1, TwoNamesStruct2 } twonames;
  twonames                      twonamesTest1(twonames e) { return e; }
  twonamestag                   twonamesTest2(twonamestag e) { return e; }
  enum twonamestag              twonamesTest3(enum twonamestag e) { return e; }
};


TwoNamesStruct::twonames    glipbob (twonames  a,   twonamestag b,  enum twonamestag c,
                                     TwoNamesStruct::twonames     d,   TwoNamesStruct::twonamestag e,  enum TwoNamesStruct::twonamestag);
*/




/*
  class EnumClass {
    public:
      enum speed { FAST, SLOW };
      // Note: default values should be EnumClass::FAST and SWEET
      //bool blah(speed s = FAST, flavor f = SWEET) { return (s == FAST && f == SWEET); };
      bool blah(speed s = FAST) { return (s == FAST); };
  };
*/

/*
      enum speed { FAST, SLOW };
      // Note: default values should be EnumClass::FAST and SWEET
      //bool blah(speed s = FAST, flavor f = SWEET) { return (s == FAST && f == SWEET); };
      bool blah(speed s = FAST) { return (s == FAST); };
*/





/*
    typedef struct Pointf_struct {
      double		x,y;
    } Pointf_typedef;
*/









/*
namespace curly {
  namespace greasy {
    struct HairStruct {
      enum hair { blonde=0xFF0, ginger };

      typedef hair hairtd1;
      typedef HairStruct::hair hairtd2;
      typedef greasy::HairStruct::hair hairtd3;
      typedef curly::greasy::HairStruct::hair hairtd4;
      typedef ::curly::greasy::HairStruct::hair hairtd5;
      typedef hairtd1 hairtd6;
      typedef HairStruct::hairtd1 hairtd7;
      typedef greasy::HairStruct::hairtd1 hairtd8;
      typedef curly::greasy::HairStruct::hairtd1 hairtd9;
      typedef ::curly::greasy::HairStruct::hairtd1 hairtdA;

      hair                          hairTest1(hair e) { return e; }
      hairtd1                       hairTest2(hairtd1 e) { return e; }
      hairtd2                       hairTest3(hairtd2 e) { return e; }
      hairtd3                       hairTest4(hairtd3 e) { return e; }
      hairtd4                       hairTest5(hairtd4 e) { return e; }
      hairtd5                       hairTest6(hairtd5 e) { return e; }
      hairtd6                       hairTest7(hairtd6 e) { return e; }
      hairtd7                       hairTest8(hairtd7 e) { return e; }
      hairtd8                       hairTest9(hairtd8 e) { return e; }
      hairtd9                       hairTestA(hairtd9 e) { return e; }
      hairtdA                       hairTestB(hairtdA e) { return e; }

//      ::colour                      colourTest1(::colour e) { return e; }
//      enum colour                   colourTest2(enum colour e) { return e; }
//      namedanon                     namedanonTest1(namedanon e) { return e; }
//      AnonSpace::namedanonspace      namedanonspaceTest1(AnonSpace::namedanonspace e) { return e; }

//      treesglobaltd1                treesGlobalTest1(treesglobaltd1 e) { return e; }
//      treesglobaltd2                treesGlobalTest2(treesglobaltd2 e) { return e; }
//      treesglobaltd3                treesGlobalTest3(treesglobaltd3 e) { return e; }
//      treesglobaltd4                treesGlobalTest4(treesglobaltd4 e) { return e; }
//      treesglobaltd5                treesGlobalTest5(treesglobaltd5 e) { return e; }

    };


    HairStruct::hair                hairTest1(HairStruct::hair e) { return e; }
    HairStruct::hairtd1             hairTest2(HairStruct::hairtd1 e) { return e; }
    HairStruct::hairtd2             hairTest3(HairStruct::hairtd2 e) { return e; }
    HairStruct::hairtd3             hairTest4(HairStruct::hairtd3 e) { return e; }
    HairStruct::hairtd4             hairTest5(HairStruct::hairtd4 e) { return e; }
    HairStruct::hairtd5             hairTest6(HairStruct::hairtd5 e) { return e; }
    HairStruct::hairtd6             hairTest7(HairStruct::hairtd6 e) { return e; }
    HairStruct::hairtd7             hairTest8(HairStruct::hairtd7 e) { return e; }
    HairStruct::hairtd8             hairTest9(HairStruct::hairtd8 e) { return e; }
    HairStruct::hairtd9             hairTestA(HairStruct::hairtd9 e) { return e; }
    HairStruct::hairtdA             hairTestB(HairStruct::hairtdA e) { return e; }

    const HairStruct::hair &        hairTestC(const HairStruct::hair &e) { return e; }

  }


  greasy::HairStruct::hair          hairTestA1(greasy::HairStruct::hair e) { return e; }
  greasy::HairStruct::hairtd1       hairTestA2(greasy::HairStruct::hairtd1 e) { return e; }
  greasy::HairStruct::hairtd2       hairTestA3(greasy::HairStruct::hairtd2 e) { return e; }
  greasy::HairStruct::hairtd3       hairTestA4(greasy::HairStruct::hairtd3 e) { return e; }
  greasy::HairStruct::hairtd4       hairTestA5(greasy::HairStruct::hairtd4 e) { return e; }
  greasy::HairStruct::hairtd5       hairTestA6(greasy::HairStruct::hairtd5 e) { return e; }
  greasy::HairStruct::hairtd6       hairTestA7(greasy::HairStruct::hairtd6 e) { return e; }
  greasy::HairStruct::hairtd7       hairTestA8(greasy::HairStruct::hairtd7 e) { return e; }
  greasy::HairStruct::hairtd8       hairTestA9(greasy::HairStruct::hairtd8 e) { return e; }
  greasy::HairStruct::hairtd9       hairTestAA(greasy::HairStruct::hairtd9 e) { return e; }
  greasy::HairStruct::hairtdA       hairTestAB(greasy::HairStruct::hairtdA e) { return e; }
  const greasy::HairStruct::hairtdA &     hairTestAC(const greasy::HairStruct::hairtdA &e) { return e; }

}

curly::greasy::HairStruct::hair                    hairTestkkk(curly::greasy::HairStruct::hair e) { return e; }

using curly::greasy::HairStruct;
HairStruct::hair                    hairTestC1(HairStruct::hair e) { return e; }

*/



/*
enum colour {red, green = 5};

//enum colour2 {red, mauve};

class mmm {
public:
enum maturity {green = 55, seasoned};
//enum ddd {red};
};
*/





/*
enum {kkk};
typedef enum {jjj} Outer;

void
foo_outer (Outer  an_arg);

struct Obscure {

  enum colour {red, green, blue};

  void colbar (colour   an_arg_aname);

  enum Zero {};
  enum One {one};
  enum Two {two, twoagain};
  typedef enum Empty {};
  typedef enum {kkkk} AlsoEmpty;
  typedef enum {jjjj} AlsoEmpty_jjj;

  typedef enum {lll} Inner;
  void foo_inner (Inner   an_arg);
};
*/




/*
class mmm
{
public:

   typedef int  kkk;
};



mmm::kkk
foobar (mmm::kkk   a_kkk,  int   an_int);




typedef int  outer_int;

outer_int
boobar (outer_int   a_kkk,  int   an_int);
*/







//int kkk;


//class kkk;

//struct jjj;



//struct _Gts;
//typedef struct _Gts Gts;

//Gts*  gts_surface_traverse_new (int   f);



//#include "foo.h"


//void bar (foo   the_foo);

/*
void
fooey (double**  N);
*/


/*
typedef struct
  {
    char    twiddle[64];
  }
bar;
*/
