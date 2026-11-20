/* A small C library. */

#include <string.h>

#define MAX_NAME   16
#define VERSION    3
#define MASK       (0xF0 | 0x0C)

typedef enum { STOPPED, RUNNING = 4, FINISHED } State;

typedef struct {
  int    id;
  double weight;
  char   name [MAX_NAME];
  State  state;
} Record;

typedef union {
  int   as_int;
  float as_float;
} Number;

typedef struct Node {
  int          value;
  struct Node* next;
} Node;

typedef int (*Visitor) (int value, void* context);

int           counter = 5;
double        ratio   = 2.5;
Record        the_record;
int           samples [4] = { 10, 20, 30, 40 };

static int    square        (int x)                         { return x * x; }
static void   bump          (void)                          { counter++; }
static int    name_length   (const char* text)              { return (int) strlen (text); }
static const char* greeting (void)                          { return "hello from C"; }

static Record make_record   (int id, double weight)         { Record r;  memset (&r, 0, sizeof r);  r.id = id;  r.weight = weight;  strcpy (r.name, "made");  r.state = RUNNING;  return r; }
static double weight_of     (Record r)                      { return r.weight; }
static void   rename_record (Record* r, const char* name)   { strncpy (r->name, name, MAX_NAME - 1); }
static State  advance       (State s)                       { return s == STOPPED ? RUNNING : FINISHED; }

static int    as_int        (Number n)                      { return n.as_int; }

static int    sum_array     (int* values, int count)        { int s = 0;  for (int i = 0; i < count; i++) s += values [i];  return s; }
static void   fill_array    (int* values, int count, int v) { for (int i = 0; i < count; i++) values [i] = v + i; }

static int    list_length   (Node* n)                       { int c = 0;  while (n) { c++;  n = n->next; }  return c; }
static int    visit         (Node* n, Visitor v, void* ctx) { int s = 0;  while (n) { s += v (n->value, ctx);  n = n->next; }  return s; }
