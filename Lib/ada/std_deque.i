/* -----------------------------------------------------------------------------
 * std_deque.i
 *
 * std::deque for Ada.
 * ----------------------------------------------------------------------------- */

%{
#include <deque>
#include <stdexcept>
%}

namespace std {

    template<class T> class deque {
      public:
        // The data members are those of the GNU libstdc++ implementation, so that
        // the Ada record has the layout of the C++ object.
        void*        impl_M_map;
        size_t       impl_M_map_size;
        void*        impl_M_start__M_cur;
        void*        impl_M_start__M_first;
        void*        impl_M_start__M_last;
        void*        impl_M_start__M_node;
        void*        impl_M_finish__M_cur;
        void*        impl_M_finish__M_first;
        void*        impl_M_finish__M_last;
        void*        impl_M_finish__M_node;

        deque();
        %extend {
            deque(size_t n) {                                  // Made by a function, as the element type may have no default constructor.
                return swig_ada_new_sized< std::deque< T > > (n);
            }
        }
        deque(const deque& other);
        ~deque();

        size_t size() const;
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();

        void push_front(const T& x);
        void push_back(const T& x);
        void pop_front();
        void pop_back();
        const T& front() const;
        const T& back() const;

        %extend {
            const T& get(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("deque index out of range");
            }
            void set(int i, const T& x) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("deque index out of range");
            }
        }
    };
}
