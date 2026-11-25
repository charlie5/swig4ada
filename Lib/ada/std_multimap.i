/* -----------------------------------------------------------------------------
 * std_multimap.i
 *
 * std::multimap for Ada.
 * ----------------------------------------------------------------------------- */

%{
#include <map>
%}

namespace std {

    // The allocator is a parameter of the template, with its default, as C++ has it, so that a partial specialisation
    // of a header which names it ('template <typename T, typename A> struct convert<std::list<T, A>>', of yaml-cpp) is
    // one of which an instance is a case (see 'std_vector.i').
    //
    template<class T> class allocator;

    template<class K, class T, class Compare = std::less<K>, class Alloc = std::allocator<std::pair<const K, T> > > class multimap {
      public:
        // The data members are those of the GNU libstdc++ implementation, so that
        // the Ada record has the layout of the C++ object.
        void*        _M_t__M_impl__M_key_compare;
        int          _M_t__M_impl__M_header__M_color;
        void*        _M_t__M_impl__M_header__M_parent;
        void*        _M_t__M_impl__M_header__M_left;
        void*        _M_t__M_impl__M_header__M_right;
        size_t       _M_t__M_impl__M_node_count;

        multimap();
        multimap(const multimap& other);
        ~multimap();

        size_t size() const;
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();

        size_t erase(const K& x);
        size_t count(const K& x) const;

        %extend {
            void add(const K& key, const T& x) {
                self->insert(std::pair<K,T >(key, x));
            }
            bool has_key(const K& key) {
                return self->find(key) != self->end();
            }
        }
    };
}
