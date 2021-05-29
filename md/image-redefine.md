# Ada 2022: Redefining the `'Image` attribute
 
This post is a part of [the Ada 2022 series](https://github.com/reznikmm/ada-howto/tree/ce-2021).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2021?filepath=%2Fhome%2Fjovyan%2Fnb%2Fimage-redefine.ipynb)

 
 * [About Jupyter Ada Kernel](https://github.com/reznikmm/ada-howto/blob/master/md/Hello_Ada.md).

### Ada 2022 activation
Firstly, let's activate Ada 2022 support in the compiler.
Usually we do this by `-gnat2022` option in compiler command line or in the project file
(preferred). But in this notebook we will do this by the `pragma Ada_2022`.
Also we will need the `Text_IO` package.


```Ada
pragma Ada_2022;

with Ada.Text_IO;
```

In Ada 2022 you can redefine `'Image` attribute for your type. Corresponding syntax has been changed several times. Let's see how does it work in GNAT Community 2021.

Firstly, you need some package:


```Ada
with Ada.Strings.Text_Buffers;
```

Then, for your type you will define a new aspect `Put_Image`:


```Ada
package Source_Locations is
   type Source_Location is record
      Line   : Positive;
      Column : Positive;
   end record
     with Put_Image => My_Put_Image;

   procedure My_Put_Image
     (Output : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : Source_Location);
end Source_Locations;

package body Source_Locations is

   procedure My_Put_Image
     (Output : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : Source_Location)
   is
      Line   : constant String := Value.Line'Image;
      Column : constant String := Value.Column'Image;
      Result : constant String :=
        Line (2 .. Line'Last) & ':' & Column (2 .. Column'Last);
   begin
      Output.Put (Result);
   end My_Put_Image;

end Source_Locations;
```

Let's define some object


```Ada
Line_10 : Source_Locations.Source_Location := (Line => 10, Column => 1);
```

Now print its `'Image`


```Ada
Ada.Text_IO.Put_Line ("Text position: " & Line_10'Image);
```




    Text position: 10:1




Looks like it works.

### What's the `Root_Buffer_Type`?

Let's see how it is defined in `Ada.Strings.Text_Buffers` package.

```Ada
type Root_Buffer_Type is abstract tagged limited private;

procedure Put
  (Buffer : in out Root_Buffer_Type;
   Item   : in     String) is abstract;

```

Besides `Put` there are also `Wide_Put`, `Wide_Wide_Put`, `Put_UTF_8`, `Wide_Put_UTF_16`.
And `New_Line`, `Increase_Indent`, `Decrease_Indent`.


## References:
 * [Ada Reference Manual 2022 Draft](http://www.ada-auth.org/standards/2xaarm/html/AA-4-10.html)
 * [AI12-0020-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0020-1.TXT)
 * [AI12-0384-2](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/ai12s/AI12-0384-2.TXT)
 * [RFC](https://github.com/AdaCore/ada-spark-rfcs/blob/ccde7846cfabd9c465179f80ae27ae634a3d69db/considered/rfc-string_stream_in_put_image.rst) and [comments](https://github.com/AdaCore/ada-spark-rfcs/pull/17)
 * [Unicode Strings in Ada 2012](https://two-wrongs.com/unicode-strings-in-ada-2012.html)
----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).

