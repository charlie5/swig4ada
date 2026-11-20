/* -----------------------------------------------------------------------------
 * std_multimap.i
 *
 * std::multimap for Ada.
 * ----------------------------------------------------------------------------- */

%{
#include <map>
%}

namespace std {

    template<class K, class T, class C = std::less<K> > class multimap {
      public:
        // The data members are those of the GNU libstdc++ implementation, so that
        // the Ada record has the layout of the C++ object.
        void*        _M_t__M_impl__M_key_compare;
        int          _M_t__M_impl__M_header__M_color;
        void*        _M_t__M_impl__M_header__M_parent;
        void*        _M_t__M_impl__M_header__M_left;
        void*        _M_t__M_impl__M_header__M_right;
        size_t       _M_t__M_impl__M_node_count;

        typedef size_t size_type;
        typedef K key_type;
        typedef T mapped_type;

        multimap();
        multimap(const multimap& other);

        size_type size() const;
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();

        size_type erase(const key_type& x);
        size_type count(const key_type& x) const;

        %extend {
            void add(const key_type& key, const mapped_type& x) {
                self->insert(std::pair<K,T >(key, x));
            }
            bool has_key(const key_type& key) {
                return self->find(key) != self->end();
            }
        }
    };
}
