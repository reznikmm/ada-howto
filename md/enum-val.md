# Ada 2022: Enumeration representation
 
This post is a part of [the Ada 2022 series](https://github.com/reznikmm/ada-howto/tree/ce-2021).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2021?filepath=%2Fhome%2Fjovyan%2Fnb%2Fenum-val.ipynb)

 
 * [About Jupyter Ada Kernel](https://github.com/reznikmm/ada-howto/blob/master/md/Hello_Ada.md).

### Ada 2022 activation
Firstly, let's activate Ada 2022 support in the compiler.
Usually we do this by `-gnat2022` option in compiler command line or in the project file
(preferred). But in this notebook we will do this by the `pragma Ada_2022`.
Also we will need some predefined packages.


```Ada
pragma Ada_2022;

with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Unchecked_Conversion;
```

## Enumeration types

Enumeration types in Ada are represented as integers on the machine level. But, actually, there are two mappings from enumeration to integer: a literal position and a representation value.

### Literal positions
Each enumeration literal has corresponding position in the type declaration. We can get it easily through `Type'Pos (Enum)` attribute.


```Ada
Ada.Text_IO.Put ("Pos(False) =");
Ada.Integer_Text_IO.Put (Boolean'Pos (False));
Ada.Text_IO.New_Line;
Ada.Text_IO.Put ("Pos(True)  =");
Ada.Integer_Text_IO.Put (Boolean'Pos (True));
```




    Pos(False) =          0
    Pos(True)  =          1



For reverse mapping we use `Type'Val (Int)`:


```Ada
Ada.Text_IO.Put_Line (Boolean'Val (0)'Image);
Ada.Text_IO.Put_Line (Boolean'Val (1)'Image);
```




    FALSE
    TRUE




### Representation values
The representation value defines _internal code_. It is used to store enumeration value in the memory or a CPU register. By default, enumeration representation values are the same as corresponding literal positions, but you can redefine them:


```Ada
type My_Boolean is new Boolean;
for My_Boolean use (False => 3, True => 6);
```

Here we created a copy of Boolean type and assigned it a custom representation.

In Ada 2022 we can get an integer value of the representation with `Type'Enum_Rep(Enum)` attribute:


```Ada
Ada.Text_IO.Put ("Enum_Rep(False) =");
Ada.Integer_Text_IO.Put (My_Boolean'Enum_Rep (False));
Ada.Text_IO.New_Line;
Ada.Text_IO.Put ("Enum_Rep(True)  =");
Ada.Integer_Text_IO.Put (My_Boolean'Enum_Rep (True));
```




    Enum_Rep(False) =          3
    Enum_Rep(True)  =          6



And for the reverse mapping we can use `Type'Enum_Val (Int)`:


```Ada
Ada.Text_IO.Put_Line (My_Boolean'Enum_Val (3)'Image);
Ada.Text_IO.Put_Line (My_Boolean'Enum_Val (6)'Image);
```




    FALSE
    TRUE




NOTE. The `'Val(X)/'Pos(X)` behaviour still is the same:


```Ada
Ada.Text_IO.Put ("Pos(False) =");
Ada.Integer_Text_IO.Put (My_Boolean'Pos (False));
Ada.Text_IO.New_Line;
Ada.Text_IO.Put ("Pos(True)  =");
Ada.Integer_Text_IO.Put (My_Boolean'Pos (True));
```




    Pos(False) =          0
    Pos(True)  =          1



Custom representation could be useful for integration with a low level protocol or a hardware.

## Before Ada 2022
This looks like not a big deal, but let see how it works with Ada 2012 and before. Firstly we need an integer type of matching size, then we should instantiate `Ada.Unchecked_Conversion`.


```Ada
type My_Boolean_Int is range 3 .. 6;
for My_Boolean_Int'Size use My_Boolean'Size;
function To_Int is new Ada.Unchecked_Conversion (My_Boolean, My_Boolean_Int);
function From_Int is new Ada.Unchecked_Conversion (My_Boolean_Int, My_Boolean);
```

Now we call `To_Int/From_Int` to work with representation values. And an extra type conversion needed:


```Ada
Ada.Text_IO.Put ("To_Int(False) =");
Ada.Integer_Text_IO.Put (Integer (To_Int (False)));
Ada.Text_IO.New_Line;
Ada.Text_IO.Put ("To_Int(True)  =");
Ada.Integer_Text_IO.Put (Integer (To_Int (True)));
```




    To_Int(False) =          3
    To_Int(True)  =          6



But this solution doesn't work for generic formal type (because T'Size should be a static value)!

## References:
 * [Ada Reference Manual 2022 Draft](http://www.ada-auth.org/standards/2xaarm/html/AA-13-4.html)
 * [AI12-0237-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0237-1.TXT)
 ----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).
