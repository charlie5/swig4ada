/* -----------------------------------------------------------------------------
 * std_stack.i
 *
 * std::stack for Ada, of its default container (a std::deque).
 * ----------------------------------------------------------------------------- */

%{
#include <stack>
%}

namespace std {

    template<class T> class stack {
      public:
        // The data members are those of the GNU libstdc++ implementation, so that
        // the Ada record has the layout of the C++ object: a stack is its container,
        // the protected member 'c', which is a std::deque (see std_deque.i).
        void*        c_impl_M_map;
        size_t       c_impl_M_map_size;
        void*        c_impl_M_start__M_cur;
        void*        c_impl_M_start__M_first;
        void*        c_impl_M_start__M_last;
        void*        c_impl_M_start__M_node;
        void*        c_impl_M_finish__M_cur;
        void*        c_impl_M_finish__M_first;
        void*        c_impl_M_finish__M_last;
        void*        c_impl_M_finish__M_node;

        stack();
        stack(const stack& other);
        ~stack();

        size_t size() const;
        %rename(isEmpty) empty;
        bool empty() const;

        void push(const T& x);
        void pop();
        const T& top() const;
    };
}
