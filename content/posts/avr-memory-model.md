+++
date = '2019-03-24'
draft = false
title = 'AVR Memory Model: The Practical Explanation'
tags = ['avr', 'programming', 'memory']
categories = ['technical']
+++

There is A LOT of people that have already explained this, but I personally don't feel like going through billions of
forum posts, with most of them just dying out somewhere in 2008 with no better answer than "I figured it out, thanks". 

Regardless. BIG shoutout to the amazing people at [AVR Freaks](https://www.avrfreaks.net/). They are really cool.
Seriously. Make a user and ask them about anything, and they'll help you.

## Disclaimer

I have only been debugging the memory usage of a specific ATMega chip. I don't know if other AVR chip-types use the
same, but this explanation should be valid for all MCUs that the
[avr-libc](http://www.nongnu.org/avr-libc/user-manual/index.html) package supports.

I also assume that GNU/Linux is being used on the development computer.

### Open-Source development tools

The [avr-gcc](http://www.nongnu.org/avr-libc/user-manual/pages.html) compiler chain is an open source effort to have
C/C++ for AVR Atmel chips. They do provide some rudimentary C++ support, but there's no STL and the `new` and `delete`
keywords are not implemented by default. Even purely virtual functions doesn't work out of the box. 

**But don't fret!** There are ways to implement those features manually. See my [other]() post about getting the build
environment up and running.

## The Memory Model

As the avr-libc developers [explain](http://www.nongnu.org/avr-libc/user-manual/malloc.html), there's typically not a
lot of RAM available on most many devices and therefore it's very important to keep track of how much memory you are
using.

{{< centered image="/malloc-std.png" >}}

All of these symbols `SP`, `RAMEND`, `__data_start`, `__malloc_heap_start`, etc. Can be modified in the compiler, but
the picture above gives the default layout (for an ATMega128 MCU). It goes without saying, that if you don't have an
external RAM chip, you won't be able to utilize the extra RAM space for that. Otherwise, the memory addresses are pretty
straight forward: `0x0100 => 256` bytes is the start of the memory, `0x10FF => 4351` bytes is the end. If you're
wondering where the RAM ends on your specific MCU, you can usually simply open the spec-sheet of the chip and see the
amount of available memory is in it. 
For the [ATMega128](https://www.microchip.com/wwwproducts/en/ATMEGA128) that number is 4096 (`4351 - 256 = 4095` (the
spec-sheet also counts the 0th byte)).

## The avr-libc Memory Allocators

Now for the juicy part. whenever you `malloc` something in your program, the allocator first writes a 2-byte *free-list
entry* that tells the system how big your object is.

Example:

```cpp
/* ... */
// Allocate an array of 5 integers
int* my_heap_object = static_cast<int*>(malloc(sizeof(int) * 5));
/* ... */
```

Assuming that the memory has been cleared on chip-startup, the above example ends up with the memory setup looking like
this: (Don't mind the specifc memory addresses. If you're curious, you can try doing this, by attaching `avr-gdb` to a
simulator or On Chip Debugger (OCD)). 

```
gdb: > x/16xb my_heap_object
0x800100:	0a 00 00 00 00 00 00 00 
0x800108: 	00 00 00 00 00 00 00 00
```

The first bytes at address `0x800100` are `0a` and `00`. These bytes are the *free-list* entry and explains how "big"
the object is. When reading this, we have to remember that the model is littleengine-based (meaning that the bytes are
switched), 
so we actually have the value of `0x000a`, meaning `10` in decimal. This makes a lot of sense, since we allocated 5
`int`s, that is of size 2 (16bit integers). 

The memory dump shows 16 bytes in total, so the last 4 bytes displayed in the gdb example are not part of the object.
However, if you look at the Memory Model picture again, you can see that the `__brkval` value points to the biggest
memory address that has not been allocated. In our example, if you check where the `__brkval` points to after our
allocation, we get:

```
gdb: > __brkval
$ 268
```

268 in hexadecimal is `0x10c`, and if interpreted as an address we get `0x80010c`, which fits very well with our
example, since it is exactly 12 bytes away from where the free-list entry of `my_heap_object` is located at. 

When `free`-ing the object again, the deallocator looks at the free-list entry at the given address, and wipes the
free-list entry. **This is why you should not free a dangling pointer**. Freeing something that is not really free-list
entry *will* result in undefined behaviour, and I think we all know how bad **that** is. (Even though the AVR
environment is actually very good at handling it. In my experience, it usually just crashes and starts over.) 
However, as
[explained](http://www.nongnu.org/avr-libc/user-manual/group__avr__stdlib.html#gafb8699abb1f51d920a176e695ff3be8a) in
the avrlibc documentation, freeing the `NULL` value, doesn't do anything. So remember to assign your free'd pointers to
`NULL` afterwards. 

## Wrapping up

The memory allocators of AVR can be very confusing and if you don't keep your thoughts straight when programming, you
can very easily get yourself into a lot of trouble. Since STL is not available to avr-gcc programmers, we dont have our
glorious smart pointers, so we should implement them ourselves (or use arduino's implementations). That might become a
future blogpost. 

Regardless, I hope this helps the lost souls that are trying to actually use these tools. 

{{< centered image="/6616144.png" >}}
