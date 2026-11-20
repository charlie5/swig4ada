package swig.Exceptions
--
-- Gives access to the C++ exception which a wrapper has caught.
--
-- A C++ exception does not reach Ada. A wrapper which catches one records it, and the call returns
-- as though nothing had happened. A program which calls a function that may throw therefore asks,
-- after the call, whether an exception is pending:
--
--    Result := checked_divide (A, B);
--    swig.Exceptions.check;                 -- Raises 'swig.Exceptions.Error' if C++ threw.
--
-- The record is part of every wrapper file, and holds the latest exception only. It is shared by
-- all of the wrappers and tasks of a program, so a program which calls C++ from several tasks
-- must see to it that a call and its check are not interleaved with those of another task.
--
-- A program which uses this package must be linked with a wrapper file.
--
is
   Error : exception;
   --
   -- Raised by 'check'. Its message is that of the C++ exception.


   type Kind is (None,
                 General,                   -- Any exception which is not one of the kinds below.
                 null_Reference,
                 out_of_Memory,
                 Index_out_of_Range,
                 divide_by_Zero,
                 Argument_out_of_Range,
                 IO,
                 Overflow);

   function  is_Pending      return Boolean;
   function  pending_Kind    return Kind;
   function  pending_Message return String;

   procedure clear;
   --
   -- Forgets the pending exception, if there is one.

   procedure check;
   --
   -- Does nothing when no exception is pending. Otherwise forgets the pending
   -- exception and raises 'Error' with its message.

end swig.Exceptions;
