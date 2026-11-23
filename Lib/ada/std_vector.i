/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * std_vector.i
 * ----------------------------------------------------------------------------- */

//%include <std_common.i>

%{
#include <vector>
#include <stdexcept>
%}

namespace std {
    
    template<class T> class vector {
      public:
        // The typedefs of the class, by which a header may name its types ('std::vector<int*>::const_reference').
        // The members below are declared with the types themselves.
        typedef size_t        size_type;
        typedef T             value_type;
        typedef T*            pointer;
        typedef const T*      const_pointer;
        typedef T&            reference;
        typedef const T&      const_reference;

        void*           impl_M_start;
	void*           impl_M_finish;
	void*           impl_M_end_of_storage;
        vector();
        vector(const vector& other);
        ~vector();
        %extend {
            vector(size_t n) {                                  // Made by a function, as the element type may have no default constructor.
                return swig_ada_new_sized< std::vector< T > > (n);
            }
        }
        size_t size() const;
        size_t capacity() const;
        void reserve(size_t n);
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();
        %rename(add) push_back;
        void push_back(const T& x);
        %extend {
            const T& get(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, const T& x) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };
}

namespace std {

    // A vector of bool is packed, one bit to an element, so it has a layout of its own (that of GNU libstdc++),
    // and an element is returned by value, there being no bool to refer to.
    //
    template<> class vector<bool> {
      public:

        void*           impl_M_start__M_p;
        unsigned int    impl_M_start__M_offset;
        void*           impl_M_finish__M_p;
        unsigned int    impl_M_finish__M_offset;
        void*           impl_M_end_of_storage;
        vector();
        vector(const vector& other);
        ~vector();
        vector(size_t n);
        size_t size() const;
        size_t capacity() const;
        void reserve(size_t n);
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();
        %rename(add) push_back;
        void push_back(bool x);
        %extend {
            bool get(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, bool x) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };
}

%define specialize_std_vector(T)
#warning "specialize_std_vector - specialization for type T no longer needed"
%enddef

