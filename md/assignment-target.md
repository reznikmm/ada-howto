# Ada 2022: Target Name Symbol (`@`)
 
This post is a part of [the Ada 2022 series](https://github.com/reznikmm/ada-howto/tree/ce-2021).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2021?filepath=%2Fhome%2Fjovyan%2Fnb%2Fassignment-target.ipynb)

 
 * [About Jupyter Ada Kernel](https://github.com/reznikmm/ada-howto/blob/master/md/Hello_Ada.md).

### Ada 2022 activation
Firstly, let's activate Ada 2022 support in the compiler.
Usually we do this by `-gnat2022` option in compiler command line or in the project file
(preferred). But in this notebook we will do this by the `pragma Ada_2022`.
Also we will need some predefined packages.


```Ada
pragma Ada_2022;

with Ada.Text_IO;
```

Ada 2022 introduces a new symbol `@`. It could appears only at the right side of an assignment statement. This symbol works as a name of the left side of the assignment statement. It was introduced to avoid code duplication. Instead of retyping (potentially long) name you can just use `@` wherever you need it.

The target name symbol denotes a constant, so you can't pass it into `[in] out` argument of a function.


```Ada
type Statistic is record
   Count : Natural := 0;
   Total : Float := 0.0;
end record;

My_Data : array (1 .. 5) of Float := (for J in 1 .. 5 => Float (J));

Statistic_For_My_Data : Statistic;

```

As an example, let's calculate some statistic for `My_Data` array:


```Ada
for Data of My_Data loop
   Statistic_For_My_Data.Count := @ + 1;
   Statistic_For_My_Data.Total := @ + Data;
end loop;
    
Ada.Text_IO.Put_Line (Statistic_For_My_Data'Image);
```




    
    (COUNT =>  5,
     TOTAL =>  1.50000E+01)




The left hand side evaluated just once, no matter how many `@` it has. Let's check this by introducing a function call. This function prints a line each time it's called:


```Ada
function To_Index (Value : Positive) return Positive is
begin
   Ada.Text_IO.Put_Line ("To_Index is called.");
   return Value;
end To_Index;
```

Now run an assignment statement:


```Ada
My_Data (To_Index (1)) := @ ** 2 - 3.0 * @;
```




    To_Index is called.




Perhaps, it looks a bit cryptic, but no better solution was found. Comparing with other languages (like `sum += x;`) this approach let you mention `@` several times on the right side of an assigment statement, so it's more flexible.

### Alternatives
In C++, the previous statement could be written with a reference type (one line longer!):
```C++
auto& a = my_data[to_index(1)];
a = a * a - 3.0 * a;
```

In Ada 2022 you can use a corresponding renaming:



```Ada
declare
   A renames My_Data (To_Index (1));
begin
   A := A ** 2 - 3.0 * A;
end;
```




    To_Index is called.




Here we use a new shorten form of the rename declaration, but anyway this looks too heavy. But even worse, this can't be used for discriminant dependent-components.


## References:
 * [Ada Reference Manual 2022 Draft](http://www.ada-auth.org/standards/2xaarm/html/AA-5-2-1.html)
 * [AI12-0125-3](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0125-3.TXT)
 ----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).

