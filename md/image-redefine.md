# Ada 2020: Redefining the `'Image` attribute
 
This post is a part of [the Ada 2020 series](https://github.com/reznikmm/ada-howto/tree/ce-2020).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2020?filepath=%2Fhome%2Fjovyan%2Fnb%2Fimage-redefine.ipynb)

 
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

In Ada 2020 you can redefine `'Image` attribute for your type. And GNAT Community Edition 2020 does it in its-own (rather ugly from my point of view) way. It differs from ARM 2020 Draft.

### A bit of history

[Initially](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/ai12s/ai12-0020-1.txt?rev=1.20),
ARG used `Ada.Streams.Root_Stream_Type'Class` to write a string image there. I didn't like this approach, because it's too low-level, error prone and nonportable, so I wrote [a proposal](https://github.com/AdaCore/ada-spark-rfcs/pull/17). I proposed to add a new abstraction Output_Text_Stream, where you can write Wide_Wide_String to. No encodings games, not CR/LF handling, no ridiculous UTF8_Strings. I have no explanation why the proposal isn't good enough nor argument why it should be done in a different way. Instead [the Standard](http://www.ada-auth.org/standards/2xaarm/html/AA-4-10.html) was [changed](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/ai12s/ai12-0340-1.txt?rev=1.3) by adding Root_Buffer_Type, where you can `Put` a `Wide_Wide_String` and `Get` a `String` with no idea how it will be converted.

### A working example
So, how GNAT CE 2020 does this? It does in a complete different way, I would say.

Firstly, you need some package:


```Ada
with Ada.Strings.Text_Output.Utils;
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
     (Sink  : in out Ada.Strings.Text_Output.Sink'Class;
      Value : Source_Location);
end Source_Locations;

package body Source_Locations is

   procedure My_Put_Image
     (Sink  : in out Ada.Strings.Text_Output.Sink'Class;
      Value : Source_Location)
   is
      Line   : constant String := Value.Line'Image;
      Column : constant String := Value.Column'Image;
      Result : constant String :=
        Line (2 .. Line'Last) & ':' & Column (2 .. Column'Last);
   begin
       Ada.Strings.Text_Output.Utils.Put_UTF_8 (Sink, Result);
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




Looks like it works. But, will it work in non-UTF-8 environment? No body knows, because it's implementation defined, I guess.

### What's the `Sink`?

Let's see how `Ada.Strings.Text_Output.Sink` is defined.

```Ada
   type Sink (<>) is abstract tagged limited private;
   type Sink_Access is access all Sink'Class with Storage_Size => 0;
   --  Sink is a character sink; you can send characters to a Sink.
   --  UTF-8 encoding is used.

   procedure Full_Method (S : in out Sink) is abstract;
   procedure Flush_Method (S : in out Sink) is abstract;

```

So,
 * How to write strings to the `Sink`?
 * Why should I use UTF-8?
 * Will it work in non-utf-8 environment?
 * How to write a muliline image in a portable way?
 * Will it do a correct Unicode handling for me?
 * Can I use my-own `Sink` to stream value image into a DB or XML, for instance?
 * Can we convince the ARG to do this better or just open the discussion to the community? 

I don't know. Do I like this? Not at all.

Do you?

## References:
 * [Ada Reference Manual 2020 Draft](http://www.ada-auth.org/standards/2xaarm/html/AA-4-10.html)
 * [AI12-0020-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0020-1.TXT)
 * [AI12-0340-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0340-1.TXT)
 * [RFC](https://github.com/AdaCore/ada-spark-rfcs/blob/ccde7846cfabd9c465179f80ae27ae634a3d69db/considered/rfc-string_stream_in_put_image.rst) and [comments](https://github.com/AdaCore/ada-spark-rfcs/pull/17)
 * [Unicode Strings in Ada 2012](https://two-wrongs.com/unicode-strings-in-ada-2012.html)
----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).

