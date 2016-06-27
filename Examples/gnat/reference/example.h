/* File : example.h */

class Vector {
private:
  double x,y,z;
public:
  Vector() : x(2), y(4), z(8) { };
  Vector(double x, double y, double z) : x(x), y(y), z(z) { };
  friend Vector operator+(const Vector &a, const Vector &b);
  char *print();
};

class VectorArray {
private:
  Vector *items;
  int     maxsize;
public:
  VectorArray(); // added til Gnat non-default construcotrs are ready
  VectorArray(int maxsize);
  ~VectorArray();
  Vector &operator[](int);
  int size();
};



  
