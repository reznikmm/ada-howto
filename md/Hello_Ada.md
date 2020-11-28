# Jupiter Ada kernel

The kernel accepts an Ada program piece by piece. A piece could be:
1. A sequence of [context clauses](http://www.ada-auth.org/standards/rm12_w_tc1/html/RM-10-1-2.html#S0253):


```Ada
with Ada.Text_IO;
```

2. A sequence of [declarative items](http://www.ada-auth.org/standards/rm12_w_tc1/html/RM-3-11.html#S0087) to be elaborated:


```Ada
Name : constant String := "World";
```

3. A sequence of [statements](http://www.ada-auth.org/standards/rm12_w_tc1/html/RM-5-1.html#S0146) to be executed:


```Ada
Ada.Text_IO.Put_Line ("Hello " & Name);
```




    Hello World




Note: If one of declarative item requires a completion, then it should be in the same cell:


```Ada
package P is
   procedure Proc;
end;

package body P is
   procedure Proc is
   begin
      Ada.Text_IO.Put_Line ("Here is Proc!");
   end;
end;
```

There are also some "magic" commands:


```Ada
%lsmagic
```




    Available line magics:
    %lsmagic? %alr? %%output? %%writefile? %gargs? %cargs? %largs? %bargs?



You can use `%alr` magic command to install dependencies from the
[Ada Library Repository](https://alire.ada.dev/). Only shared library
projects are supported.


```Ada
%alr -q with spawn
```




    Do you want to proceed?
    Using default: Yes







    Do you want Alire to automatically update your project file with the new dependency solution?
    Using default: Yes
    Do you want Alire to remember this choice?
    Using default: No




After installing a crate with `%alr` you can use its units in `with` clauses:


```Ada
with Spawn.Environments;
```


```Ada
Ada.Text_IO.Put_Line (Spawn.Environments.System_Environment.Contains ("PATH")'Image);
```




    TRUE



