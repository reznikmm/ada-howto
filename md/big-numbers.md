# Ada 2020: Big Numbers
 
This post is a part of [the Ada 2020 series](https://github.com/reznikmm/ada-howto/tree/ce-2021).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2021?filepath=%2Fhome%2Fjovyan%2Fnb%2Fbig-numbers.ipynb)

 
 * [About Jupyter Ada Kernel](https://github.com/reznikmm/ada-howto/blob/master/md/Hello_Ada.md).

### Ada 2020 activation
Firstly, let's activate Ada 2020 support in the compiler.
Usually we do this by `-gnat2022` option in compiler command line or in the project file
(preferred). But in this notebook we will do this by the `pragma Ada_2022`.
Also we will need some predefined packages, especially `Ada.Numerics.Big_Numbers.Big_Integers`.


```Ada
pragma Ada_2022;

with Ada.Text_IO;
with Ada.Numerics.Big_Numbers.Big_Integers;
use  Ada.Numerics.Big_Numbers.Big_Integers;
```

## Big_Integers

The package `Ada.Numerics.Big_Numbers.Big_Integers` contains a type `Big_Integer` and corresponding operation like comparison (`=, <, >, <=, >=`), arithmetic (`+, -, *, /, rem, mod, abs, **`), `Min`, `Max` and `Greatest_Common_Divisor`. The type has `Integer_Literal` and `Put_Image` aspects redefined. So you can use it in a natural way.


```Ada
Ada.Text_IO.Put_Line (Big_Integer'Image(2 ** 256));
```




     115792089237316195423570985008687907853269984665640564039457584007913129639936




## Tiny RSA implementation
Now we can implement [the RSA algorithm](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) in a few lines of code. The main operation of RSA is **(mᵈ) mod n**. But you can't just write `m ** d`, because these are really big numbers and the result doesn't fit the memory. However if you keep intermediate result by `mod n` during mᵈ calculation then it will work. Let's write this operation as a function:


```Ada
function Power_Mod (M, D, N : Big_Integer) return Big_Integer;
--  Calculate M ** D mod N

function Power_Mod (M, D, N : Big_Integer) return Big_Integer is

   function Is_Odd (X : Big_Integer) return Boolean is
     (X mod 2 /= 0);

   Result : Big_Integer := 1;
   Exp    : Big_Integer := D;
   Mult   : Big_Integer := M mod N;
begin
   while Exp /= 0 loop
      --  Loop invariant is Power_Mod'Result = Result * Mult**Exp mod N
      if Is_Odd (Exp) then
         Result := (Result * Mult) mod N;
      end if;

      Mult := Mult ** 2 mod N;
      Exp := Exp / 2;
   end loop;

   return Result;
end Power_Mod;
```

Let's check this with the example from [Wikipedia](https://en.wikipedia.org/wiki/RSA_(cryptosystem)). In the example the _public key_ is (n = 3233, e = 17) and _the message_ is m = 65. The encrypted message is mᵉ mod n = 65¹⁷ mod 3233 = 2790 = c.


```Ada
Ada.Text_IO.Put_Line (Power_Mod (M => 65, D => 17, N => 3233)'Image);
```




     2790




To decrypt it with the _public key_ (n = 3233, d = 413) we need to calculate cᵈ mod n = 2790⁴¹³ mod 3233


```Ada
Ada.Text_IO.Put_Line (Power_Mod (M => 2790, D => 413, N => 3233)'Image);
```




     65




So 65 is the original message m. Easy!

## Example JWS Using RSASSA-PKCS1-v1_5 SHA-256

Will this work with keys of a _real size_? Let check out implementation with another example.

[RFC 7515](https://tools.ietf.org/html/rfc7515#page-38) has an example for JSON Web Signature (JWS). They want to sign this piece of data:


```Ada
Header_And_Payload : String :=
  "eyJhbGciOiJSUzI1NiJ9" &
  "." &
  "eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFt" &
  "cGxlLmNvbS9pc19yb290Ijp0cnVlfQ";
```

The signature calculation uses RSA, so it needs a private key. In the example, they provide us a 2048 bits private key encoded into Base64 (url):


```Ada
--  Modulus
N_Image : constant String :=
 "ofgWCuLjybRlzo0tZWJjNiuSfb4p4fAkd_wWJcyQoTbji9k0l8W26mPddx" &
 "HmfHQp-Vaw-4qPCJrcS2mJPMEzP1Pt0Bm4d4QlL-yRT-SFd2lZS-pCgNMs" &
 "D1W_YpRPEwOWvG6b32690r2jZ47soMZo9wGzjb_7OMg0LOL-bSf63kpaSH" &
 "SXndS5z5rexMdbBYUsLA9e-KXBdQOS-UTo7WTBEMa2R2CapHg665xsmtdV" &
 "MTBQY4uDZlxvb3qCo5ZwKh9kG4LT6_I5IhlJH7aGhyxXFvUK-DWNmoudF8" &
 "NAco9_h9iaGNj8q2ethFkMLs91kzk2PAcDTW9gb54h4FRWyuXpoQ";

--  Private exponent
D_Image : constant String :=
 "Eq5xpGnNCivDflJsRQBXHx1hdR1k6Ulwe2JZD50LpXyWPEAeP88vLNO97I" &
 "jlA7_GQ5sLKMgvfTeXZx9SE-7YwVol2NXOoAJe46sui395IW_GO-pWJ1O0" &
 "BkTGoVEn2bKVRUCgu-GjBVaYLU6f3l9kJfFNS3E0QbVdxzubSu3Mkqzjkn" &
 "439X0M_V51gfpRLI9JYanrC4D4qAdGcopV_0ZHHzQlBjudU2QvXt4ehNYT" &
 "CBr6XCLQUShb1juUO1ZdiYoFaFQT5Tw8bGUl_x_jTj3ccPDVZFD9pIuhLh" &
 "BOneufuBiB4cS98l2SR_RQyGWSeWjnczT0QU91p1DhOVRuOopznQ";

```

So we need a function to decode base64 into a big integer. It's rather simple. We loop over each character, convert it into base64 "digit" and make a result from such digits.


```Ada
function From_Base_64 (Text : String) return Big_Integer;
--  Cast base64 text into a big integer.

function From_Base_64 (Text : String) return Big_Integer is
   Result : Big_Integer := 0;
   Next   : Integer;
begin
   for Char of Text loop
      Next :=
        (case Char is
           when 'A' .. 'Z' =>
             Character'Pos (Char) - Character'Pos ('A'),
           when 'a' .. 'z' =>
             Character'Pos (Char) - Character'Pos ('a') + 26,
           when '0' .. '9' =>
             Character'Pos (Char) - Character'Pos ('0') + 52,
           when '-' => 62,
           when '_' => 63,
           when others => raise Constraint_Error);

      Result := Result * 64 + To_Big_Integer (Next);
   end loop;

   --  Trim extra zeros from Result
   return Result / 2 ** (Text'Length * 6 mod 8);
end From_Base_64;
```

(We need some result rounding, because base64 text actually represents byte array, not 6-bit integers sequence).

Calculation of the signature involves SHA-256 of the payload, so let's import GNAT implementation for this:


```Ada
with GNAT.SHA256;
with Ada.Streams;
```

The signature is calculated for a message, that contains a fixed header appended with SHA-512 of the payload:


```Ada
use type Ada.Streams.Stream_Element_Array;

SHA_256 : Ada.Streams.Stream_Element_Array :=
  GNAT.SHA256.Digest (Header_And_Payload);

Message : Ada.Streams.Stream_Element_Array :=
 [0, 1] & [1 .. 202 => 16#FF#] & [0] &
 [16#30#, 16#31#, 16#30#, 16#0d#, 16#06#, 16#09#, 16#60#, 16#86#,
  16#48#, 16#01#, 16#65#, 16#03#, 16#04#, 16#02#, 16#01#, 16#05#,
  16#00#, 16#04#, 16#20#] & 
 SHA_256;
```

The message here is a byte array. Let's cast it to a big number with this simple function:


```Ada
function From_Bytes (Data : Ada.Streams.Stream_Element_Array) return Big_Integer;
--  Cast byte array into a big number

function From_Bytes (Data : Ada.Streams.Stream_Element_Array) return Big_Integer is
   Result : Big_Integer := 0;
begin
   for Byte of Data loop
      Result := Result * 256 + To_Big_Integer (Integer (Byte));
   end loop;

   return Result;
end From_Bytes;
```

Now we are ready to calculate the signature.


```Ada
N : constant Big_Integer := From_Base_64 (N_Image);  --  modulus
D : constant Big_Integer := From_Base_64 (D_Image);  --  exponent
M : constant Big_Integer := From_Bytes(Message);     --  message

Signature : Big_Integer := Power_Mod(M, D, N);
```

How can we check the result? The example in RFC contains an expected result. It's base64 encoded also:


```Ada
S_Image : constant String :=
 "cC4hiUPoj9Eetdgtv3hF80EGrhuB__dzERat0XF9g2VtQgr9PJbu3XOiZj5RZmh7" &
 "AAuHIm4Bh-0Qc_lF5YKt_O8W2Fp5jujGbds9uJdbF9CUAr7t1dnZcAcQjbKBYNX4" &
 "BAynRFdiuB--f_nZLgrnbyTyWzO75vRK5h6xBArLIARNPvkSjtQBMHlb1L07Qe7K" &
 "0GarZRmB_eSN9383LcOLn6_dO--xi12jzDwusC-eOkHWEsqtFZESc6BfI7noOPqv" &
 "hJ1phCnvWh6IeYI2w9QOYEUipUTI8np6LbgGY9Fs98rqVt5AXLIhWkWywlVmtVrB" &
 "p0igcN_IoypGlUPQGe77Rw";


S : Big_Integer := From_Base_64 (S_Image);

```

So we just compare decoded value with our result:


```Ada
Ada.Text_IO.Put_Line("Match:" & Boolean'Image(Signature = S));
```




    Match:TRUE




This is the end of the RSA example.

Besides Big_Integer, Ada 2020 provides [Big Reals](http://www.ada-auth.org/standards/2xaarm/html/AA-A-5-7.html).

## References:
 * [Ada Reference Manual 2020 Draft](http://www.ada-auth.org/standards/2xaarm/html/AA-A-5-6.html)
 * [AI12-0208-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0208-1.TXT)
 ----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).
