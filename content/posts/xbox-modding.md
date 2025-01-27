+++
date = '2025-01-27'
draft = false
title = 'Softmod your Original Xbox Today'
tags = ['technical', 'games', 'modding']
categories = ['technical', 'personal']
+++

If you want to skip the personal story, the tutorial part starts [here]({{< ref "xbox-modding.md#softmodding-the-xbox" >}}).

The original Xbox is a phenominal little machine.
In this post I will go over my journey of modding my own personal xbox.
Feel free to follow along, but this is mostly just a recollection of my journey for the sake of writing it down.

## First Things First
If you own an Xbox Original and you haven't removed the clock capacitor yet, DO IT NOW. YOU SHOULD'VE DONE IT SEVERAL
YEARS AGO, IT *WILL* KILL YOUR XBOX.
Even if you are not sure if it's removed or not, please check to make sure. This is incredibly important.

With that out of the way, let's begin.

## The Beginnings
It all started with I was about 14 years old.
I remember it clearly.
It was early 2010 and I had saved up my allowance for a while and wanted to buy something for myself.
So as any 14 year old buy with marginal financial freedom, I went to the local GameStop just to browse.
I was already an avid Halo fan, so I was looking around at the Halo 3 and Gears of War copies that they had, as well as
the other xbox 360 games showing off on the store shelves.
But alas, I did not own an Xbox 360, or any (real) videogame console for that matter.
So I opted to buy something else, I don't remember what excactly.
What I do remember is that when I went up to the counter, I saw that they had a used Xbox original (back then we called
it the xbox 1) for sale!
And only for 1001kr! Which was... not excactly cheap at the time, but hey, I didn't know better.
I had saved up just over 1000kr! And the Halo 2 Collectors edition was bundled with it! Holy crap!!
This was a match made in heaven and I bought it on the spot in favor of whatever else I wanted.
Proud, and with my heart pumping (this was the biggest purchase I had ever done at the time), I took it home and
deliberately hid it from my mother, because she wouldn't approve of me spending my hard earned allowance on a videogame
console.

A couple of years earlier, my sister and I received a small CRT TV with an in-built DVD player for our rooms so we 
could watch movies and (some) TV in our rooms. This CRT had an S-VIDEO input.
I remember that it was such an adventure trying to figure out how to plug the Xbox to the TV. The figure-8 cable scared
me when it sparked when I plugged it into the Xbox and I thought I broke it, but I just had to change the input on the
TV. And when I finally got it working I was rewarded with the comforting green glow of the internal clock needing to be
set. I promptly pressed 'A' without changing anything, inserted the Halo 2 disc and played for the first time on my very
own video game console.

I sneak-play'ed so much Halo 2, that I missed a lot of homework, and sleep. I distinctly remember one night I played
(with no sound mind you) for uncountable hours. Oh to be a kid again. I know that at one point my mom found out and she
didn't actually care that I "wasted" the money. She only cared about my bedtime (ugh!) and my homework (double ugh!) -
which is fair, but still.

A couple months after the purchase, I wanted to try out the Xbox Live features and play Halo 2 online (I did not know
you'd have to pay for it) so I found a way to connect an ethernet cable to the box and tried connecting.
But I was not able to get any connection. I kept trouble-shooting and then I realized that LITERALLY THE WEEK BEFORE
Microsoft had closed the Xbox Original live service down. What a bummer dude. Welp. At least I had the Halo 2 campaign.

## Getting a Taste for Modding
Much later. I am now in my ??'s.

TODO:
 - Building my own PC
 - Building skills
 - Fixing my laptop (which broke all the time)
 - Modding the Wii
 - Modding the Playstation 2

The first game console that I modded was a Wii that I bought on a flea-market for next to nothing.
Side tangent: The Wii is the _easiest_ console to softmod. You only need an SDCard - that's it.
This Wii modding lit a fire under me, and I started taking apart 

## Softmodding the Xbox {#softmodding-the-xbox}
There are a couple of directions you can take when it comes to modding the OG Xbox.
I will be exclusively *softmodding* mine, as if I were to solder anything that is required for hardmodding it, I would
at best: brick the console, and at worst burn my apartment to the ground.
This mod _does_ require purchasing some hardware though, namely:

 - **An xbox (male) to USB (female) adapter.**

   These are increasingly difficult to find, so if you tend to drag your feet on projects like these (like I tend to)
   buy it now! Or you might have to make one yourself - and I just said that soldering is out of the picture for me.
   It has to look like this:

   {{< centered image="/xbox-to-usb.png" style="width: 40%" >}}

 - **An older USB stick.**

   The Xbox will reject most modern USB flash drives - it has to be a fairly small one (I used a 4GiB one), and no, you
   cannot just set the partition sizes to be small, the physical hardware has to be old. You probably have one lying
   around, or your parents might have one in their "random electronics" drawer.

 - **A DVD burner and some (writable and blank) DVDs.**

   This is mostly just to burn a single DVD with the softmodding tools on it. I think you can buy pre-burned discs, but
   if you have a DVD burner (generally just a good doohickey to have), it's much easier to just use `xfburn` to burn the
   disc yourself.

### Software
I am using GNU/Linunx, but all of these are also available on Microsoft Windows - I haven't checked if OSX have these,
but I wouldn't be surprised to find that they also work there.

 - `xfburn` for burning DVDs.

## TODO:
 - Link to MrMario (check for peertube link as a backup)
 - Xbox softmodding tool disc
 - Extras (chimp)
 - Holy crap the IDE hot-swapping

## Upgrading the Xbox
Now that we have softmodded it, we can choose to upgrade the aging IDE harddrive with a slightly newer and larger
harddrive! This is totally optional, but I highly recommend it as it'll enable you to store many more games on the 
console itself, rather than mucking about with DVD discs and a dying DVD drive.

## Thanks
I would like to thank [bringus studios](https://www.youtube.com/@BringusStudios) for keeping the interest of console
hacking alive and a special thanks to [mr mario](https://www.youtube.com/@MrMario2011) for his fantastic tutorials.
Please check both of these creators out.

{{< centered image="/6616144.png" >}}
