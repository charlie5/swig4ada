/* File : example.h */
#include <stdio.h>

class Shape {
public:
  Shape() {
    nshapes++;
    printf ("SHAPE CONSTRUCT\n");
  }
  virtual ~Shape() {
    nshapes--; printf ("SHAPE DESTRUCT\n");
  };
  double  x, y;   
  void    move(double dx, double dy);
  virtual double area(void) = 0;
  virtual double perimeter(void) = 0;
  static  int nshapes;
};

class Circle : public Shape {
private:
  double radius;
public:
//  Circle(double r) : radius(r) { };
//  Circle() : radius(0.5) { };
  Circle();

  virtual double area(void);
  virtual double perimeter(void);
};

class Square : public Shape {
private:
  double width;
public:
  Square();
//  Square(double w) : width(w) { };
  Square(double w);

  virtual double area(void);
  virtual double perimeter(void);
};




  
