/* -----------------------------------------------------------------------------
 * std_list.i
 *
 * std::list for Ada.
 * ----------------------------------------------------------------------------- */

%{
#include <list>
#include <stdexcept>
%}

namespace std {

    // The allocator is a parameter of the template, with its default, as C++ has it, so that a partial specialisation
    // of a header which names it ('template <typename T, typename A> struct convert<std::list<T, A>>', of yaml-cpp) is
    // one of which an instance is a case (see 'std_vector.i').
    //
    template<class T> class allocator;

    template<class T, class Alloc = std::allocator<T> > class list {
      public:
        // The data members are those of the GNU libstdc++ implementation, so that
        // the Ada record has the layout of the C++ object.
        void*        impl_M_node__M_next;
        void*        impl_M_node__M_prev;
        size_t       impl_M_node__M_size;

        list();
        list(const list& other);
        ~list();

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
        void reverse();
    };
}
