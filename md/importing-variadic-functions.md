# Ada 2020: Interfacing C variadic functions
 
This post is a part of [the Ada 2020 series](https://github.com/reznikmm/ada-howto/tree/ce-2020).
 
You can launch this notebook with Jupyter Ada Kernel by clicking this button:
 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/ce-2020?filepath=%2Fhome%2Fjovyan%2Fnb%2Fimporting-variadic-functions.ipynb)

 
 * [About Jupyter Ada Kernel](https://github.com/reznikmm/ada-howto/blob/master/md/Hello_Ada.md).

### Ada 2020 activation
Firstly, let's activate Ada 2020 support in the compiler.
Usually we do this by `-gnat2020` option in compiler command line or in the project file
(preferred). But in this notebook we will do this by the `pragma Ada_2020`.
Also we will need some predefined packages.


```Ada
pragma Ada_2020;

with Ada.Numerics;
with Ada.Text_IO;
with Interfaces.C;

```

# Variadic functions
In C, [variadic functions](https://en.cppreference.com/w/c/variadic) take a variable number of arguments and have an ellipsis as the last parameter of the declaration. The typical example is

```C
int printf(const char* format, ...);
```

Usually, in Ada, we bind such a function with required parameters:


```Ada
procedure printf_double
  (format : Interfaces.C.char_array;
   value  : Interfaces.C.double)
     with Import,
       Convention    => C,
       External_Name => "printf";
```

Then we call it as usual Ada function:


```Ada
printf_double (Interfaces.C.To_C ("Pi=%f"), Ada.Numerics.π);
```




    Pi=3.141593



Unfortunately, often it just doesn't work this way. Some [ABI](https://en.wikipedia.org/wiki/Application_binary_interface) use different calling conventions for variadic functions. For instance [the AMD64 ABI](https://software.intel.com/sites/default/files/article/402129/mpx-linux64-abi.pdf) specifies:

> *  `%rax` - with variable arguments passes information about the number of vector registers used
>
> *  `%xmm0–%xmm1` - used to pass and return floating point arguments

This means, if we write (in C):

```C
printf("%d", 5);
```

Then the compiler will place 0 into `%rax`, because we don't pass any float argument (but we could). And in Ada, if we write:

```ada
procedure printf_int
  (format : Interfaces.C.char_array;
   value  : Interfaces.C.int)
     with Import,
       Convention    => C,
       External_Name => "printf";

printf_int (Interfaces.C.To_C ("d=%d"), 5);
```

The Ada compiler will not use `%rax` register at all (since you can't put any float argument, because there is no float parameter in the Ada wrapper function declaration). As result, you will get crash, stack corruption or any other undefined behavior.

To fix this, Ada 2020 provides a new family of calling convention names - `C_Variadic_`_N_:

> The convention
> `C_Variadic_`*n* is the calling convention for a variadic C function
> taking *n* fixed parameters and then a variable number of
> additional parameters.

So, the right way to bind `printf` function is:


```Ada
procedure printf_int
  (format : Interfaces.C.char_array;
   value  : Interfaces.C.int)
     with Import,
       Convention    => C_Variadic_1,
       External_Name => "printf";
```

And the next call won't crash on any supported platform:


```Ada
printf_int (Interfaces.C.To_C ("d=%d"), 5);
```




    d=5



First time, I encountered this problem for [the Matreshka SQLite](https://forge.ada-ru.org/matreshka) binding on PowerPC, because it calls:

```C
int sqlite3_config(int, ...);
```

Then it failed to work with:

```C
void syslog(int priority, const char *format, ...);
```

in [a daemon library](https://www.ada-ru.org/ada-daemons2)(the article in Russian).

So, I consider this as a very useful fix for Ada-to-C interfacing facility.


## References:
 * [Ada Reference Manual 2020 Draft](http://www.ada-auth.org/standards/2xaarm/html/AA-B-3.html)
 * [AI12-0028-1](http://www.ada-auth.org/cgi-bin/cvsweb.cgi/AI12s/AI12-0028-1.TXT)
 * [StackOverflow question](https://stackoverflow.com/questions/35819037/variadic-function-in-ada-c-ada-binding)
 ----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).

