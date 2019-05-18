with
     ada.Characters.Handling;


package body a_Namespace
is
   use name_Vectors,
       ada.Characters.Handling;



   procedure add_Name (Self      : in out Item;
                       name_Text : in     unbounded_String)
   is
      the_Name : Name_view := self.fetch_Name (name_Text);
   begin
      if the_Name = null
      then
         the_Name      := new Name;
         the_Name.Text := name_Text;

         append (self.Names, the_Name);
      end if;

      the_Name.overload_Count := the_Name.overload_Count + 1;
   end add_Name;



   function fetch_Name (Self      : in     Item;
                        name_Text : in     unbounded_String) return Name_view
   is
      Cursor : name_Cursor := First (self.Names);
   begin

      while has_Element (Cursor)
      loop
         if to_Lower (to_String (name_Text)) = to_Lower (to_String (Element (Cursor).Text))
         then
            return Element (Cursor);
         end if;

         next (Cursor);
      end loop;

      return null;
   end fetch_Name;


end a_Namespace;
