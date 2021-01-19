# VSS

Virtual strings library now in [Alire](https://alire.ada.dev)! So, setup should be easy step:


```Ada
%alr -q with vss
```




    Do you want to proceed?
    Using default: Yes







    Do you want Alire to automatically update your project file with the new dependency solution?
    Using default: Yes
    Do you want Alire to remember this choice?
    Using default: No




## Conversions
Let's start with a procedure to print a `Virtual_String`. We need some standard Ada packages for it.


```Ada
with Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;

with VSS.Strings;
with VSS.Strings.Conversions;
```

For now we can convert a `Virtual_String` only to UTF-8 (mostly for debug purposes, because it uses a secondary/primary? stack). Instead we provide several streams, as you see later.


```Ada
procedure Print (Text : VSS.Strings.Virtual_String) is
   UTF_8 : Ada.Strings.UTF_Encoding.UTF_8_String :=
     VSS.Strings.Conversions.To_UTF_8_String (Text);

   Wide : Wide_Wide_String :=
     Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Decode (UTF_8);
begin
   Ada.Wide_Wide_Text_IO.Put_Line (Wide);
end Print;
```

To get a Virtual string from a literal we have a conversion function from `Wide_Wide_String` type:


```Ada
Literal : constant Wide_Wide_String := "Hi, 🐧! Привет";

Hi : VSS.Strings.Virtual_String := VSS.Strings.To_Virtual_String (Literal);
```

Now print it!


```Ada
Print (Hi);
```




    Hi, 🐧! Привет




## Direct properties

The `Virtual_String` has some properties and we can easy get them:


```Ada
Ada.Text_IO.Put_Line ("Is_Empty=" & Hi.Is_Empty'Image);
Ada.Text_IO.Put_Line ("Hash=" & Hi.Hash'Image);
Ada.Text_IO.Put_Line ("Character_Length=" & Hi.Character_Length'Image);
```




    Is_Empty=FALSE
    Hash= 2272830368935134545
    Character_Length= 13




## Iterating over a string

For now there is a character iterator. Other (grapheme, word, line, etc) iterators could be defined in the future.


```Ada
with VSS.Strings.Iterators.Characters;
```

An iterator has a character index and UTF8/16 offsets.


```Ada
declare
   Each : VSS.Strings.Iterators.Characters.Character_Iterator :=
     Hi.First_Character;
begin
   while Each.Forward loop
      Ada.Text_IO.Put (Each.Character_Index'Image);
      Ada.Text_IO.Put ("  UTF8"  & Each.UTF8_Offset'Image);
      Ada.Text_IO.Put ("  UTF16" & Each.UTF16_Offset'Image);
      Ada.Text_IO.Put ("  => ");
      Ada.Wide_Wide_Text_IO.Put_Line ((1 => Wide_Wide_Character (Each.Element)));
   end loop;
end;
```




     2  UTF8 1  UTF16 1  => i
     3  UTF8 2  UTF16 2  => ,
     4  UTF8 3  UTF16 3  =>  
     5  UTF8 4  UTF16 4  => 🐧
     6  UTF8 8  UTF16 6  => !
     7  UTF8 9  UTF16 7  =>  
     8  UTF8 10  UTF16 8  => П
     9  UTF8 12  UTF16 9  => р
     10  UTF8 14  UTF16 10  => и
     11  UTF8 16  UTF16 11  => в
     12  UTF8 18  UTF16 12  => е
     13  UTF8 20  UTF16 13  => т




## String vectors

An important missing features in Ada is a string vector. VSS has this as a tagged type.


```Ada
with VSS.String_Vectors;
with Ada.Characters.Wide_Wide_Latin_1;
```

Currently, besides `Append`, `Length` and `Element` subprograms, it's used to split lines with standard (but run-time configurable) separators.


```Ada
Text : VSS.Strings.Virtual_String := VSS.Strings.To_Virtual_String
  ("aaa" & Ada.Characters.Wide_Wide_Latin_1.LF &
   "bbb" & Ada.Characters.Wide_Wide_Latin_1.CR & Ada.Characters.Wide_Wide_Latin_1.LF &
   "ccc" & Ada.Characters.Wide_Wide_Latin_1.CR &
   "ddd");

Vector : VSS.String_Vectors.Virtual_String_Vector := Text.Split_Lines;
```

Let's see how it works:


```Ada
for Line of Vector loop
   Print (Line);
end loop;
```




    aaa
    bbb
    ccc
    ddd




Note, no extra line between CR and LF:


```Ada
Ada.Text_IO.Put_Line (Vector.Length'Image);
```




     4




## Stream_Element_Buffer

The `Stream_Element_Array` is a indefinite type and not very handy in situation when you don't know its size in advance. For such use we provide a `Stream_Element_Buffer`.


```Ada
with Ada.Streams;
with VSS.Stream_Element_Buffers;
with VSS.Stream_Element_Buffers.Conversions;
```

The function `Conversions.Unchecked_To_String` uses the stack, but useful in some cases.


```Ada
declare
   Buffer : VSS.Stream_Element_Buffers.Stream_Element_Buffer;
begin
   Buffer.Append (71);
   Buffer.Append (72);
   Buffer.Append (73);

   for J in 1 .. Buffer.Length loop
      Ada.Text_IO.Put (Buffer.Element (J)'Image);
   end loop;
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line
     (VSS.Stream_Element_Buffers.Conversions.Unchecked_To_String (Buffer));
end;
```




     71 72 73
    GHI




## Streams
The `VSS.Text_Streams` package provides
 * `Input_Text_Stream` and `Output_Text_Stream` interfaces.
 * `Memory_UTF8_Output_Stream` implementation of the `Output_Text_Stream` collects UTF-8 representation of the text into a memory buffer.


```Ada
with VSS.Text_Streams.Memory;
```


```Ada
declare
   Stream : VSS.Text_Streams.Memory.Memory_UTF8_Output_Stream;
   Ok     : Boolean;

   Each   : VSS.Strings.Iterators.Characters.Character_Iterator :=
     Hi.First_Character;
begin
   while Each.Forward loop
      Stream.Put (Each.Element, Ok);
   end loop;

   Ada.Text_IO.Put_Line
     (VSS.Stream_Element_Buffers.Conversions.Unchecked_To_String
       (Stream.Buffer));
end;
```




    i, 🐧! Привет




# JSON

The JSON subproject provides JSON reader and writer to process JSON in a streaming way. It's comparable with StaX API for XML (like SAX but without callbacks).

## JSON_Simple_Writer


```Ada
with VSS.JSON.Streams.Writers;
```

You provide a text output stream and then create JSON by triggering events.


```Ada
declare
   Output : aliased VSS.Text_Streams.Memory.Memory_UTF8_Output_Stream;
   Writer : VSS.JSON.Streams.Writers.JSON_Simple_Writer;
begin
   Writer.Set_Stream (Output'Unchecked_Access);
   Writer.Start_Document;
   Writer.Start_Array;
   Writer.Null_Value;
   Writer.Boolean_Value (True);
   Writer.String_Value (Hi);
   Writer.Integer_Value (123);
   Writer.End_Array;
   Writer.End_Document;

   Ada.Text_IO.Put_Line
     (VSS.Stream_Element_Buffers.Conversions.Unchecked_To_String
       (Output.Buffer));
end;
```




    [null,true,"Hi, 🐧! Привет",123]




## JSON_Simple_Reader

The reader works in opposite direction. After providing an input text stream, you can read events in a loop from the reader.


```Ada
with Test_Text_Streams;
with VSS.JSON.Streams.Readers.Simple;
```

Let's connect Reader and Writer with a simple `case` statement:


```Ada
declare
   use all type VSS.JSON.Streams.Readers.JSON_Event_Kind;

   JSON   : String := "[null, true, 123]";
   Input  : aliased Test_Text_Streams.Memory_UTF8_Input_Stream;
   Reader : VSS.JSON.Streams.Readers.Simple.JSON_Simple_Reader;
   Writer : VSS.JSON.Streams.Writers.JSON_Simple_Writer;
   Output : aliased VSS.Text_Streams.Memory.Memory_UTF8_Output_Stream;
begin
   Reader.Set_Stream (Input'Unchecked_Access);
   Writer.Set_Stream (Output'Unchecked_Access);

   for Char of JSON loop
      Input.Buffer.Append (Character'Pos (Char));
   end loop;

   loop
      case Reader.Read_Next is
         when Start_Document =>
            Writer.Start_Document;
         when End_Document =>
            Writer.End_Document;

            exit;
         when Start_Array =>
            Writer.Start_Array;
         when End_Array =>
            Writer.End_Array;
         when Null_Value =>
            Writer.Null_Value;
         when Boolean_Value =>
            Writer.Boolean_Value (Reader.Boolean_Value);
         when Number_Value =>
            Writer.Number_Value (Reader.Number_Value);
         when others =>
            null;
      end case;
   end loop;

   Ada.Text_IO.Put_Line
     (VSS.Stream_Element_Buffers.Conversions.Unchecked_To_String
       (Output.Buffer));
end;
```




    [null,true,123]




# Conclusion
