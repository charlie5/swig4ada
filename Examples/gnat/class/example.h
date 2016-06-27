/* File : example.h */

#include <iostream>

using namespace std;



class Shape {
protected:

//  enum { DEFAULT_GROW_BY = 64 };

public:

          //Shape();
          Shape()
{ 
  cout << "in Shape constructor\n";
  nshapes++;
}

  virtual ~Shape();

  double  x, y;   
  void    move(double dx, double dy) const;
  //void    move(double dx, double dy);
  virtual double area(void) = 0;
  virtual double perimeter(void) = 0;
  static  int nshapes;
};



class Circle : public Shape {
private:
public:
  double radius;

  //Circle();
  Circle() : radius(5.0) 
{
  cout << "in Circle constructor\n"; 
};


  virtual ~Circle() {};
  //Circle()         : radius(5.0) {    cout << "in Circle constructor\n"; };
  //Circle(double r) : radius(r) { };
  //virtual double area(void);
  virtual double area     (void) {return 3.1415*radius*radius;}
  virtual double perimeter(void);

};



class Square : public Shape {
private:
  double width;

//  Square (const Square&  from);            //tbd: protected construcotrs break the c wrapper file.

public:
  //Square();
  Square() : width(5.0) 
{
  cout << "in Square constructor\n"; 
};


  virtual ~Square() {};
  //Square() :         width(5.0) {    cout << "in Square constructor\n"; };
  //Square(double w) : width(w) { };
  virtual double area(void);
  virtual double perimeter(void);
};




  
