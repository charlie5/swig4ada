/* file: example.h */
//#include <iostream>


//long double      kkk (long double jjj);


//typedef int   gint;

//enum hair {blonde, ginger};
enum tree {blonde, ginger};

class hair {};



//typedef int    foo;

//class foo {};





/*
struct gsl_vector
{
  double *data;
};
*/




/*
typedef struct 
{
  double *data;
} 
gsl_vector;
*/


/*
typedef struct
{
  int      vector;
} 
  a_gsl_vector_const_view;



//typedef  a_gsl_vector_const_view     gsl_vector_const_view;
typedef  const a_gsl_vector_const_view     gsl_vector_const_view;
*/





//#include <string>

//typedef double    dVector3[4];

/*
extern double sum (dVector3      by);
extern int mult  (dVector3*     by);
*/

//typedef char**  my_char_ptr_type;


//extern double sum (char*      by[]);



//typedef int    int32;



/*
struct dxJoint;

typedef struct dxJoint *dJointID;
*/








/*
struct TreesClass 
{
  enum trees {oak, fir, pine };
};



typedef  const TreesClass::trees  treesglobaltd7;


treesglobaltd7                      
treesTestO (treesglobaltd7   e) 
{ return e; }
*/

/*
//typedef int (*IMP_kkk)(int, int, ...);


typedef double dReal;

typedef dReal dVector3[4];



//IMP_kkk
//test_fn ();

class Methodk {};

typedef Methodk*   Method;


//typedef int     Method;


struct Foo
{ public:
  dVector3 Z;
  int      Y [5];
  Method   X [5];

};

*/



//typedef dReal dMatrix3[4*3];

/*
void    
rods_proc (double   value[4],     dVector3   argy)
{
  std::cout << "args => " << argy[0] << argy[1] << argy[2] << argy[3] << std::endl;
  std::cout << "vals => " << value[0] << value[1] << value[2] << value[3] << std::endl;
};
*/


/*
void    
rods_func (const dVector3   argy)
{
  std::cout << "args => " << argy[0] << argy[1] << argy[2] << argy[3] << std::endl;
  //return 5.0;
};
*/

//dReal*    
//rods_func ()
//{
//  //std::cout << "args => " << argy[0] << argy[1] << argy[2] << argy[3] << std::endl;
//  return 0;
//};



/*
dReal    
rods_func_matrix (double   value[4],    const dMatrix3   argy)
{
  std::cout << "args => " << argy[0] << argy[1] << argy[2] << argy[3] << std::endl;
  std::cout << "vals => " << value[0] << value[1] << value[2] << value[3] << std::endl;
  return 5.0;
};
*/

//struct dxWorld;         /* dynamics world */

//typedef struct dxWorld *dWorldID;


//dWorldID    test_1 (dWorldID   a_World);





/*
enum colours {red, green, blue};


void test_colours (colours*   the_colour);
*/


/*
class Klass
{
protected:
  enum { DEFAULT_GROW_BY = 64 };
}
*/

/*
typedef struct dSurfaceParameters {
  int mode;
  float mu;

} dSurfaceParameters;



typedef struct dContactGeom {
  int   pos;
  float depth;
} dContactGeom;



typedef struct dContact {
  dSurfaceParameters surface;
  dContactGeom geom;
  dVector3 fdir1;
} dContact;



typedef struct dStopwatch {
  double time;       
  unsigned long cc[2];  
} dStopwatch;
*/








//struct dxGeom;          /* geometry (collision object) */

//typedef struct dxGeom *dGeomID;


//struct dxGeom
//{
//  int kkk;
//};



/*
typedef struct dJointFeedback 
{
  dVector3   f1; 
  dVector3   t1; 
  dVector3   f2; 
  dVector3   t2; 
} 
  dJointFeedback;

*/