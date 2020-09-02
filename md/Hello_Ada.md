# Jupyter Ada Kernel

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/reznikmm/ada-howto/master?filepath=%2Fhome%2Fjovyan%2Fnb%2FHello_Ada.ipynb)

This is a short overview of the Jupyter Ada Kernel.
[The Jupyter](https://en.wikipedia.org/wiki/Project_Jupyter) is
a web-based interactive development environment capable to run dozens of programming languages.
The Jupyter Notebook is an open-source web application that allows you to create and share documents that contain live code, equations, visualizations and narrative text.

[The Jupyter Ada Kernel](https://github.com/reznikmm/jupyter/) provides support for
[Ada programming language](https://en.wikipedia.org/wiki/Ada_(programming_language)).

To suit [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) workflow
and allow code and text to be interspersed the kernel accepts an Ada program piece by piece. In Jupyter Notebook such pieces are called _cells_. Usually cells are executed in order, because one call can depend on another. You can execute cell by pressing `Ctrl+Enter`
on it or by using a menu or toolbar icons. Take a look at _User Interface Tour_ in _Help_ menu.

Our kernel supports next Ada program pieces:

## 1. Context Clause

A cell can contain a sequence of [context clauses](http://www.ada-auth.org/standards/rm12_w_tc1/html/RM-10-1-2.html#S0253), such as `with`/`use`-clause or `pragma`:


```Ada
with Ada.Text_IO;
```

## 2. Declarative Item

A sequence of [declarative items](http://www.ada-auth.org/standards/rm12_w_tc1/html/RM-3-11.html#S0087) to be elaborated:


```Ada
Name : constant String := "World";
```

The kernel allows you to freely redefine names in subsequent cells, but in case of ambiguity you should prefix the name with `Run_`_N_`.` prefix (where _N_ is a cell run number visible in square brackets):


```Ada
Greeting : constant String := "Hello " & Run_2.Name;
```

## 3. Statement
A cell can contain a sequence of [statements](http://www.ada-auth.org/standards/rm12_w_tc1/html/RM-5-1.html#S0146) to be executed:


```Ada
Ada.Text_IO.Put_Line (Greeting);
```




    Hello World




## 4. Program Units

If a declarative item requires a completion, then both should be in the same cell:


```Ada
package P is
   procedure Proc;
end;

package body P is
   procedure Proc is
   begin
      Ada.Text_IO.Put_Line ("Here is Proc!");
   end;
end;
```

**Note: a cell can't contain pieces of different kinds!**

## 5. Magic

There are also some "magic" commands:


```Ada
%lsmagic
```




    Available line magics:
    %lsmagic? %%output? %%writefile?



----

Do you like this? Support us on [patreon](https://www.patreon.com/ada_ru)!

Live discussions: [Telegram](https://t.me/ada_lang), [Matrix](https://matrix.to/#/#ada-lang:matrix.org).

