/* File : example.c */

#include "example.h"
#define M_PI 3.14159265358979323846

/* Move the shape to a new location */
void Shape::move(double dx, double dy) {
  x += dx;
  y += dy;
}

int Shape::nshapes = 0;


Circle::Circle() : radius(0.5)
{
  printf ("Circle::Cirllce\n");
};

Circle::Circle(double r) : radius(r)
{
  printf ("Circle::Circle\n");
};


double Circle::area0(void) {
  printf ("Circle::area0\n");
  return M_PI*radius*radius;
}


double Circle::area(void) {
  printf ("Circle::area\n");
  return M_PI*radius*radius;
}

double Circle::perimeter(void) {
  printf ("Circle::perimeter\n");
  return 2*M_PI*radius;
}






Square::Square()
{ width = 1.0;
}


Square::Square(double w) : width(w)
{ };



double Square::area(void) {
  return width*width;
}

double Square::perimeter(void) {
  return 4*width;
}
