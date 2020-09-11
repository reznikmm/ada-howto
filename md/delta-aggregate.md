# Ada 2020: Delta Aggregates
 
This post is a part of [the Ada 2020 series](https://github.com/reznikmm/ada-howto/tree/ce-2020).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2020?filepath=%2Fhome%2Fjovyan%2Fnb%2Fdelta-aggregate.ipynb)

 
 * [About Jupyter Ada Kernel](https://github.com/reznikmm/ada-howto/blob/master/md/Hello_Ada.md).

### Ada 2020 activation
Firstly, let's activate Ada 2020 support in the compiler.
Usually we do this by `-gnat2020` option in compiler command line or in the project file
(preferred). But in this notebook we will do this by the `pragma Ada_2020`.
Also we will need some predefined packages.



```Ada
pragma Ada_2020;

with Ada.Text_IO;
```

## Delta aggregate for records
Somtimes you need to create a copy of an object with a few modifications. Before Ada 2020 it would involve a dummy object declaration or an aggregate with associations for each property. Without "a declaration expression", the dummy object approach doesn't work in a contract aspects. A limited component won't work with dummy object approach neither. While an re-listing properties in an aggregate could be too hard. 

So, in Ada 2020, you can use a _delta aggregate_. For instance:


```Ada
type Vector is record
   X, Y, Z : Float;
end record;

Point_1 : constant Vector := (X => 1.0, Y => 2.0, Z => 3.0);
Projection_1 : constant Vector := (Point_1 with delta Z => 0.0);
```


```Ada
Ada.Text_IO.Put_Line (Projection_1'Image);
```




    
    (x =>  1.00000E+00,
     y =>  2.00000E+00,
     z =>  0.00000E+00)




The more component you have, the more you will like the delta aggregate.

## Delta aggregate for arrays

There is also the delta aggregate for arrays. You can change array elements with it, but you can't change array bounds. Also, it works only for one-dimention arrays of non-limited component.


```Ada
type Vector_3D is array (1 .. 3) of Float;

Point_2 : constant Vector_3D := [1.0, 2.0, 3.0];
Projection_2 : constant Vector_3D := [Point_2 with delta 3 => 0.0];
```


```Ada
Ada.Text_IO.Put_Line (Projection_2'Image);
```




    
    [ 1.00000E+00,  2.00000E+00,  0.00000E+00]




You can use parentheses for array aggregates, but you can't use square brackets for record aggregates.

## References:
 * [Ada Reference Manual 2020 Draft](http://www.ada-auth.org/standards/2xaarm/html/AA-4-3-4.html)
 * [AI12-0127-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0127-1.TXT)
 ----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).

