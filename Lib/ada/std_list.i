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

    template<class T> class list {
      public:
        // The data members are those of the GNU libstdc++ implementation, so that
        // the Ada record has the layout of the C++ object.
        void*        impl_M_node__M_next;
        void*        impl_M_node__M_prev;
        size_t       impl_M_node__M_size;

        typedef size_t size_type;
        typedef T value_type;
        typedef const value_type& const_reference;

        list();
        list(const list& other);

        size_type size() const;
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();

        void push_front(const value_type& x);
        void push_back(const value_type& x);
        void pop_front();
        void pop_back();
        const_reference front() const;
        const_reference back() const;
        void reverse();
    };
}
