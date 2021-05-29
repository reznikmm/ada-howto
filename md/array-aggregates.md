# Ada 2022: Advanced Array/Container Aggregates
 
This post is a part of [the Ada 2022 series](https://github.com/reznikmm/ada-howto/tree/ce-2021).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2021?filepath=%2Fhome%2Fjovyan%2Fnb%2Farray-aggregates.ipynb)

 
 * [About Jupyter Ada Kernel](https://github.com/reznikmm/ada-howto/blob/master/md/Hello_Ada.md).

### Ada 2022 activation
Firstly, let's activate Ada 2022 support in the compiler.
Usually we do this by `-gnat2022` option in compiler command line or in the project file
(preferred). But in this notebook we will do this by the `pragma Ada_2022`.
If you want to use square brackets syntax you also need `-gnatX` compiler option or `pragma Extensions_Allowed (On);` in the source file.
Also we will need some predefined packages.


```Ada
pragma Ada_2022;
pragma Extensions_Allowed (On);

with Ada.Text_IO;
```

## Square brackets
    
In Ada 2022 you can use square brackets in array aggregates. Square brackets usage simplifies writing of an empty aggregate and a single element aggregate. Consider this:


```Ada
type Integer_Array is array (Positive range <>) of Integer;
                             
Old_Style_Empty : Integer_Array := (1 .. 0 => <>);
New_Style_Empty : Integer_Array := [];

Old_Style_One_Item : Integer_Array := (1 => 5);
New_Style_One_Item : Integer_Array := [5];
```

Apart from zero and one element aggregates, there is no other difference between brackets and parentheses in array aggregates.

##  Iterated Component Association

There is new kind of component association:


```Ada
Vector : Integer_Array := [for J in 1 .. 5 => J * 2];
```

The association starts with **for** keyword, just like a quantified expression. It declares an index parameter that can be used in a component computation.


```Ada
Ada.Text_IO.Put_Line (Integer_Array'Image(Vector));
```




    
    [ 2,  4,  6,  8,  10]




Of cource, iterated component association could nest and be nested in another associtation (iterated or not). But you can't mix iterated and not iterated association in one list. Here is a square matrix definition:


```Ada
declare
   Matrix : array (1 .. 3, 1 .. 3) of Positive :=
    (for J in 1 .. 3 =>
      (for K in 1 .. 3 => J * 10 + K));
begin
   Ada.Text_IO.Put_Line (Matrix'Image);
end;
```




    
    [
     [ 11,  12,  13],
    
     [ 21,  22,  23],
    
     [ 31,  32,  33]]




Intresting that such aggregates were originally proposed more than 25 years ago!

The same syntax is defined for container aggregates. And they are now implemented in GNAT Community Edition 2021. Let's see them for standard containers.


```Ada
with Ada.Containers.Vectors;
with Ada.Containers.Ordered_Maps;
```

Consider a vector of integer.


```Ada
package Int_Vectors is new Ada.Containers.Vectors
  (Positive, Integer);

X : Int_Vectors.Vector := [1, 2, 3];
```

The underlying code creates an empty container and appends 1, 2, 3 one element a time.

For maps it looks a bit different.


```Ada
package Float_Maps is new Ada.Containers.Ordered_Maps
  (Integer, Float);

Y : Float_Maps.Map := [-10 => 1.0, 0 => 2.5, 10 => 5.51];
```

Let's see the `Y'Image`:


```Ada
Ada.Text_IO.Put_Line (Y'Image);
```




    
    [-10 =>  1.00000E+00,  0 =>  2.50000E+00,  10 =>  5.51000E+00]





## References:
 * [Ada Reference Manual 2022 Draft](http://www.ada-auth.org/standards/2xaarm/html/AA-4-3-3.html)
 * [AI12-0212-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0212-1.TXT)
 * [AI12-0306-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0306-1.TXT)
 * [AI12-0212-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/ai12s/AI12-0212-1.TXT)
 ----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).



```Ada

```
