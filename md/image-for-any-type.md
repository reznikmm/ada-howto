# Ada 2020: `'Image` attribute for any type
 
This post is a part of [the Ada 2020 series](https://github.com/reznikmm/ada-howto/tree/ce-2020).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2020?filepath=%2Fhome%2Fjovyan%2Fnb%2Fimage-for-any-type.ipynb)

 
 * [About Jupyter Ada Kernel](https://github.com/reznikmm/ada-howto/blob/master/md/Hello_Ada.md).

### Ada 2020 activation
Firstly, let's activate Ada 2020 support in the compiler.
Usually we do this by `-gnat2020` option in compiler command line or in the project file
(preferred). But in this notebook we will do this by the `pragma Ada_2020`.
Also we will need the `Text_IO` package.


```Ada
pragma Ada_2020;

with Ada.Text_IO;
```

### `X'Image` attribute
If you missed
[Technical Corrigendum 1 changes](https://reznikmm.github.io/ada-auth/rm-4-NC/RM-0-1.html)
(they were published in February 2016)
then you probably don't know that the `'Image` attribute can be applied now to a value. So, instead of `My_Type'Image (Value)` you can just write `Value'Image`, but only if the `Value` is a
[_name_](https://reznikmm.github.io/ada-auth/rm-4-NC/RM-4-1.html#S0091).
So, these two statements are equal:


```Ada
Ada.Text_IO.Put_Line (Ada.Text_IO.Page_Length'Image);

Ada.Text_IO.Put_Line
  (Ada.Text_IO.Count'Image (Ada.Text_IO.Page_Length));
```




     0
     0




### `'Image` in Ada 2020 works for any type

Now you can apply `'Image` attribute for any type, including records, array, access and private types. Let's see how this works.


```Ada
type Vector is array (Positive range <>) of Integer;

V1 : aliased Vector := (1, 2, 3);

type Text_Position is record
   Line, Column : Positive;
end record;
                      
Pos : Text_Position := (Line => 10, Column => 3);
                      
type Vector_Access is access all Vector;

V1_Ptr : Vector_Access := V1'Access;
```

Now you can convert these objects to string and print:


```Ada
Ada.Text_IO.Put_Line (V1'Image);

Ada.Text_IO.Put_Line (Pos'Image);
Ada.Text_IO.New_Line;
Ada.Text_IO.Put_Line (V1_Ptr'Image);
```




    
    [ 1,  2,  3]
    
    (line =>  10,
     column =>  3)
    
    (access 7ff5c5717138)




Note square brackets in array image. In Ada 2020 array aggregates could be written this way!

### References

More details:
 * [AI12-0020-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/ai12s/ai12-0020-1.txt)
 * [ARM 4.10 Image Attributes](https://reznikmm.github.io/ada-auth/aarm-5-NC/AA-4-10.html)
 
----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).

