# Ada 2020: User-Defined Literals
 
This post is a part of [the Ada 2020 series](https://github.com/reznikmm/ada-howto/tree/ce-2020).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2020?filepath=%2Fhome%2Fjovyan%2Fnb%2Fuser-defined-literals.ipynb)

 
 * [About Jupyter Ada Kernel](https://github.com/reznikmm/ada-howto/blob/master/md/Hello_Ada.md).

### Ada 2020 activation
Firstly, let's activate Ada 2020 support in the compiler.
Usually we do this by `-gnat2020` option in compiler command line or in the project file
(preferred). But in this notebook we will do this by the `pragma Ada_2020`.
Also we will need some predefined packages.


```Ada
pragma Ada_2020;

with Ada.Wide_Wide_Text_IO;
with Ada.Characters.Conversions;
```

### New aspects
In Ada 2020 you can use string, integer or real literals with your type. To do so just specify one or more new aspects:
 * `Integer_Literal`
 * `Real_Literal`
 * `String_Literal`
 
For the demo let's define all three of them for some simple type and see how it works. We will use a `Wide_Wide_String` component for internal representation:


```Ada
type My_Type (Length : Natural) is record
    Value : Wide_Wide_String (1 .. Length);
end record
  with String_Literal => From_String,
    Real_Literal      => From_Real,
    Integer_Literal   => From_Integer;

function From_String (Value : Wide_Wide_String) return My_Type is
  ((Length => Value'Length, Value => Value));

function From_Real (Value : String) return My_Type is
  ((Length => Value'Length,
    Value  => Ada.Characters.Conversions.To_Wide_Wide_String (Value)));
   
function From_Integer (Value : String) return My_Type renames From_Real;

```

Let's define a `Print` shortcut procedure:


```Ada
procedure Print (Self : My_Type) is
begin
   Ada.Wide_Wide_Text_IO.Put_Line (Self.Value);
end Print;
```

Let's see how the compiler converts literals for us:


```Ada
Print ("Test ""string""");
Print (123);
Print (16#DEAD_BEAF#);
Print (2.99_792_458e+8);
```




    Test "string"
    123
    16#DEAD_BEAF#
    2.99_792_458e+8




As you see real and integer literals are presented in exact form, while for string literals compiler drops surrounding quotes and escapes. The compiler translates these literals into function calls.

### Turn Ada into JavaScript

Do you know that `'5'+3` in JavaScript is `53`?

    > '5'+3
    '53'


Now we can get the same success with Ada! But before we need to define a custom `+` operator:


```Ada
function "+" (Left, Right : My_Type) return My_Type is
  (Left.Length + Right.Length, Left.Value & Right.Value);
```

See how it works:


```Ada
Print ("5" + 3);
```




    53




## References:
 * [Ada Reference Manual 2020 Draft](http://www.ada-auth.org/standards/2xaarm/html/AA-4-2-1.html)
 * [AI12-0249-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0249-1.TXT)
 * [AI12-0342-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0342-1.TXT)
 ----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).

