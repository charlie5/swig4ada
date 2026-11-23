separate (ada_Language)


procedure bind_constructors_of_abstract_Class (Self : access Item;   the_Class : in Node_Pointer)
--
--  An abstract class cannot be constructed, and the core gives it no constructor. A class which is derived
--  from it in Ada needs one all the same, to construct the part of its object which is the abstract class.
--
--  The wrapper is therefore given a concrete class which is derived from the abstract class, has each of its
--  constructors and defines each of its pure virtual functions (which are never called, as Ada replaces the
--  vtable of the object by that of its own type). A constructor of the abstract class is bound to a function
--  which constructs an object of the concrete class in the storage it is given.
--
is
   use type C.int;
   use type DOH_Pointer;
   use type swig_Module.swig_Module_view;

   package node_Vectors is new ada.Containers.Vectors (Positive, Node_Pointer);

   function plain_Name (the_Function : in Node_Pointer) return String
   is
      Name : unbounded_String := +Attribute (the_Function, "name");
   begin
      strip_Namespaces (Name);
      return to_String (Name);
   end plain_Name;

   function all_Abstracts (of_Class : in Node_Pointer) return node_Vectors.Vector
   --
   --  The pure virtual functions which a class has not defined: its own, and those of its base classes which
   --  neither it nor a class between has defined. The core's list ('abstracts') holds those of the base classes
   --  only where the class has none of its own, so the concrete class of a class with both was still abstract.
   --
   is
      Own    : constant DOH_Pointer := DOH_Pointer (get_Attribute (of_Class, "abstracts"));
      Bases  : constant DOH_Pointer := DOH_Pointer (get_Attribute (of_Class, "allbases"));
      Result : node_Vectors.Vector;

      function is_Listed (the_Function : in Node_Pointer) return Boolean
      is (for some Each of Result =>          Each = the_Function
                                     or else (         plain_Name (Each)        = plain_Name (the_Function)
                                              and then Attribute (Each, "decl") = Attribute (the_Function, "decl")));

      function is_Defined (the_Function : in Node_Pointer) return Boolean
      is
         the_Member : Node_Pointer := first_Child (of_Class);
      begin
         while the_Member /= null
         loop
            if         Attribute (the_Member, "nodeType") = "cdecl"
              and then get_Attribute (the_Member, "abstract") = null
              and then plain_Name (the_Member)       = plain_Name (the_Function)
              and then Attribute (the_Member, "decl") = Attribute (the_Function, "decl")
            then
               return True;
            end if;

            the_Member := next_Sibling (the_Member);
         end loop;

         return False;
      end is_Defined;

   begin
      if Own /= null
      then
         for Each in 0 .. DohLen (Own) - 1
         loop
            if not is_Listed (Node_Pointer (DohGetitem (Own, Each)))
            then
               Result.append (Node_Pointer (DohGetitem (Own, Each)));
            end if;
         end loop;
      end if;

      if Bases /= null
      then
         for Each in 0 .. DohLen (Bases) - 1
         loop
            for the_Function of all_Abstracts (Node_Pointer (DohGetitem (Bases, Each)))
            loop
               if         Attribute (the_Function, "nodeType") /= "destructor"
                 and then not is_Listed  (the_Function)
                 and then not is_Defined (the_Function)
               then
                  Result.append (the_Function);
               end if;
            end loop;
         end loop;
      end if;

      return Result;
   end all_Abstracts;

   the_Abstracts : constant DOH_Pointer := DOH_Pointer (get_Attribute (the_Class, "abstracts"));
   the_Name      : unbounded_String     := +("ada_concrete_" & String'(+DOH_Pointer (get_Attribute (the_Class, "name"))));
   the_cpp_Class : constant String      := (if get_Attribute (the_Class, "name") = null then ""
                                            else +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (the_Class, "name")))));
   the_Functions : unbounded_String;
   has_Constructor : Boolean := False;
   the_Child       : Node_Pointer;
   Status          : C.int with Unreferenced;
begin
   if        not Self.in_cpp_Mode
     or else the_Abstracts = null
     or else DohLen (the_Abstracts) = 0
     or else Self.current_Module /= Self.Module_top'Access                 -- The wrapper of an imported module is not written here.
     or else get_Attribute (the_Class, "allocate:private_destructor") /= null
     or else get_Attribute (the_Class, "allocate:nonew")              /= null
     or else get_Attribute (the_Class, "feature:notabstract")         /= null     -- The core has given it its constructors.
   then
      return;
   end if;

   for Each in 1 .. Length (the_Name)
   loop
      if Element (the_Name, Each) not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_'
      then
         replace_Element (the_Name, Each, '_');
      end if;
   end loop;

   --  A definition of each pure virtual function.
   --
   for the_Function of all_Abstracts (the_Class)
   loop
      begin
         if Attribute (the_Function, "nodeType") = "destructor"
         then
            return;     -- A pure virtual destructor cannot be defined within a class.
         end if;

         if get_Attribute (the_Function, "final") /= null
         then
            return;     -- A pure virtual function which is final can be defined by no class, so there is no concrete one.
         end if;

         declare
            the_Type  : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Function, "type"))));
            Name      :          unbounded_String := +Attribute (the_Function, "name");
            the_Decl  :          unbounded_String := +Attribute (the_Function, "decl");
            Qualifier :          unbounded_String;     -- That of the function itself, as in 'int f () const'.
            Reference :          unbounded_String;     -- Its reference qualifier, if any.
            Promise   : constant String           := (if Attribute (the_Function, "noexcept") = "true" then " noexcept" else "");     -- Which an override must keep.
         begin
            strip_Namespaces (Name);

            if Index (the_Decl, "r.") = 1          -- A function which is declared for an lvalue or for an rvalue alone
            then                                   -- ('int f () const &').
               Reference := +" &";
               the_Decl  := unbounded_Slice (the_Decl, 3, Length (the_Decl));

            elsif Index (the_Decl, "z.") = 1
            then
               Reference := +" &&";
               the_Decl  := unbounded_Slice (the_Decl, 3, Length (the_Decl));
            end if;

            if Index (the_Decl, "q(") = 1
            then
               declare
                  Last : constant Natural := Index (the_Decl, ").");
               begin
                  Qualifier := " " & unbounded_Slice (the_Decl, 3, Last - 1);
                  the_Decl  := unbounded_Slice (the_Decl, Last + 2, Length (the_Decl));
               end;
            end if;

            SwigType_push (the_Type, to_Doh (to_String (the_Decl)));

            if         Index (Name, "operator ") = 1
              and then Length (Name) > 9
              and then (   Element (Name, 10) in 'a' .. 'z' | 'A' .. 'Z' | '_' | ':')
              and then Slice (Name, 10, Length (Name)) not in "new" | "delete" | "new[]" | "delete[]"
            then   -- A conversion operator ('operator Other ()'), which is declared with no result type.
               append (the_Functions,   "  virtual " & Name & " ()"
                                      & Qualifier & Reference & Promise & " { abort (); }" & NL);
            else
               append (the_Functions,   "  virtual " & String'(+doh_Item (SwigType_str (the_Type, const_String (-to_String (Name)))))
                                      & Qualifier & Reference & Promise & " { abort (); }" & NL);
            end if;
         end;
      end;
   end loop;

   --  A constructor for each of those of the class.
   --
   Self.Shim.Name         := the_Name;
   Self.Shim.Constructors := null_unbounded_String;
   Self.Shim.Functions    := null_unbounded_String;

   the_Child := first_Child (the_Class);

   while the_Child /= null
   loop
      if         Attribute (the_Child, "nodeType") = "constructor"
        and then get_Attribute (the_Child, "template") = null
      then
         has_Constructor := True;

         if         not check_Attribute (the_Child, "access", "private")
           and then Attribute (the_Child, "value") /= "delete"     -- A deleted constructor ('T (const T&) = delete;') is none which can be called.
         then
            Status := Self.constructorHandler (the_Child);
         end if;
      end if;

      the_Child := next_Sibling (the_Child);
   end loop;

   if not has_Constructor
   then   -- The class has the default constructor which C++ gives it.
      declare
         the_Constructor : constant Node_Pointer := Node_Pointer (DohNewHash);
      begin
         set_Attribute (the_Constructor, "nodeType", "constructor");
         set_Attribute (the_Constructor, "name",     Attribute (the_Class, "sym:name"));
         set_Attribute (the_Constructor, "sym:name", Attribute (the_Class, "sym:name"));
         set_Attribute (the_Constructor, "access",   "public");

         Status := Self.constructorHandler (the_Constructor);
      end;
   end if;

   if Self.Shim.Functions /= ""
   then
      print_to (DOH_Pointer (Self.f_Ada),   "class " & to_String (the_Name) & " : public " & the_cpp_Class & NL
                                          & "{"                                                           & NL
                                          & "public:"                                                     & NL
                                          & to_String (Self.Shim.Constructors)
                                          & to_String (the_Functions)
                                          & "};"                                                          & NL & NL
                                          & to_String (Self.Shim.Functions));
   end if;

   Self.Shim.Name := null_unbounded_String;
end bind_constructors_of_abstract_Class;
