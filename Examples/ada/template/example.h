/* File : example.h */

// Some template definitions

template<class T> T max(T a, T b) { return  a>b ? a : b; }

template<class T> class vector {
  T *v;
  int sz;
 public:
  vector(int sz) {
    v = new T[sz];
    sz = sz;
  }
  T &get(int index) {
    return v[index];
  }
  void set(int index, T &val) {
    v[index] = val;
  }
#ifdef SWIG
  %extend {
    T getitem(int index) {
      return self->get(index);
    }
    void setitem(int index, T val) {
      self->set(index,val);
    }
  }
#endif
};

