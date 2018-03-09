enum libusb_error {
	LIBUSB_SUCCESS = 0,

	LIBUSB_ERROR_IO = -1,

	LIBUSB_ERROR_INVALID_PARAM = -2,

	LIBUSB_ERROR_ACCESS = -3,

	LIBUSB_ERROR_NO_DEVICE = -4,

	LIBUSB_ERROR_NOT_FOUND = -5,

	LIBUSB_ERROR_BUSY = -6,

	LIBUSB_ERROR_TIMEOUT = -7,

	LIBUSB_ERROR_OVERFLOW = -8,

	LIBUSB_ERROR_PIPE = -9,

	LIBUSB_ERROR_INTERRUPTED = -10,

	LIBUSB_ERROR_NO_MEM = -11,

	LIBUSB_ERROR_NOT_SUPPORTED = -12,

	LIBUSB_ERROR_OTHER = -99,
};




//void vkGetInstanceProcAddr(const char* pName);

//#define A10  19 && 20





// bool constant

//%constant bool constbool=false;
//bool foo;

//void bar (bool kkk);


/*
struct _unicap_device_t
{
   int flags;
};

typedef struct _unicap_device_t unicap_device_t;
*/







// typedef unsigned char BUFF[12]; 




/*

typedef int PaStreamCallback(
    const void *input, void *output,
    unsigned long frameCount,
//    const PaStreamCallbackTimeInfo* timeInfo,
//    PaStreamCallbackFlags statusFlags,
    void *userData );


//typedef void PaStreamCallback(void);


void   foo (PaStreamCallback*   arg);
//PaStreamCallback*   foo (PaStreamCallback*   arg);

//void Pa_OpenStream(    PaStreamCallback *streamCallback);

*/






/*
typedef struct random_state_t
  {
  int		j, k, x;
  } random_state;


random_state	random_get_state(void);
*/


/*
typedef short _Bool;
#define boolean _Bool

typedef struct population_t population;

typedef boolean (*GAgeneration_hook)(const int generation, population *pop);
*/



/*
typedef struct
{
  int _mp_alloc;	
} __mpz_struct;


typedef struct
{
  __mpz_struct _mp_num;
} __mpq_struct;


//typedef const __mpq_struct *mpq_srcptr;
typedef __mpq_struct *mpq_ptr;
*/







/*
typedef struct _GNode		GNode;

typedef void		(*GNodeForeachFunc)	(GNode	       *node,
						 int     	data);
struct _GNode
{
  GNode	  *next;
  GNode	  *prev;
  GNode	  *parent;
  GNode	  *children;
};
*/




//void foo(char* bar);
//char* foo();



/*
typedef struct _IplImage
{
    int    x;
}
IplImage;

//IplImage*  cvCreateImageHeader();
void  cvCreateImageHeader (const IplImage*   kkk);
*/


/*
void
foo (char*   arg);
*/


/*

#define FANN_EXTERNAL
#define FANN_API


struct fann;
typedef  float   fann_type;


struct fann_train_data
{
	char *errstr;

	unsigned int num_data;
	unsigned int num_input;
	unsigned int num_output;
	fann_type **input;
	fann_type **output;
};


FANN_EXTERNAL void FANN_API fann_train(struct fann *ann, fann_type * input,
									   fann_type * desired_output);


*/



/*

float**
vorbis_analysis_buffer();

*/


/*
typedef unsigned char OakFeatureReport[32];

void   
printFeatureReport (OakFeatureReport report);    
*/




/*
struct fann;


struct fann_train_data
{
   int x;
};


typedef int (* fann_callback_type) (struct fann *ann);


struct fann
{
   fann_callback_type x;
};

*/




/*
struct SDL_semaphore;
typedef struct SDL_semaphore SDL_sem;
*/



//typedef struct GLFWwindow GLFWwindow;
//void foo (GLFWwindow* arg_1);
//typedef void (* GLFWwindowposfun) (GLFWwindow*,int,int);



//typedef struct GLFWmonitor GLFWmonitor;




//enum foo {aa=0, bb=0};






// typedef uint32_t xcb_connection_t;
// typedef uint32_t xcb_window_t;






/*

class foo
{
  public:

};

class bar
{
  public:

};

*/
