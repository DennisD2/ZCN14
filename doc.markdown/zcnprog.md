# Writing programs for CP/M and ZCN		-*- outline -*-

...by Russell Marks.


# (Lack of) Copyright

This document is public domain. You can do whatever you want with it.


# Introduction

##  What this file is

This is a guide to writing programs in Z80 machine code for CP/M and
ZCN. It's intended for Z80 programmers who are new to CP/M, and the
ZCN section is intended for those new to ZCN. It may also be useful as
a reference for those already familiar with CP/M and/or ZCN.

It covers, in a reasonable amount of detail:

- Fundamental ideas behind CP/M's operation

- The BDOS functions

- zcnlib, my library of PD Z80 routines for ZCN and CP/M generally


##  ZCN? What's that?

In case you're not reading this as part of the ZCN documentation, I
should mention that ZCN is a CP/M-like OS (not quite a clone *as
such*, but very compatible with CP/M) I wrote for the Amstrad NC100,
an obscure but surprisingly good Z80-based A4 `notepad'. The machine
wasn't designed to run CP/M by any means, but the hardware is *just*
flexible enough to be able to run a specially-written `clone', and
that's what ZCN is. (I later adapted it for the NC200 and NC150.)


##  What this guide leaves out

This guide avoids describing in any detail:

- the BIOS.

- use of allocation and DPB info (particularly using them to find free
   disk space in CP/M 2.2).

- the internals of CP/M.

- RSXs etc.

Most programs shouldn't need these things.

It's fair to say my knowledge of CP/M internals is pretty shaky,
despite writing ZCN - it's really a completely different OS that just
has the same syscall interface and the like. If this doesn't make
much sense, consider the following:

- I used CP/M for the first time in May 1994.
- I started writing ZCN in July.
- I wrote my first CP/M program in m/c in September.

Admittedly, this *is* a rather odd way of going about things... :-)


# CP/M

##  Fundamental ideas

CP/M is a single-tasking OS - there is only one program running at a
time. This program is allowed to use all the available memory. This
memory available to programs is called the transient program area, or
TPA. This starts at 100h - all programs are run with (effectively) a
`CALL 100h' instruction. You should end your program with either a RET
or a jump to 0000h.


##   Memory organisation

Here's a memory map:

            ___________________
           |                   |
           |        BIOS       |  Don't overwrite the BIOS or BDOS!
           |___________________|
           |                   |  Together these are called the FDOS,
           |        BDOS       |  but this term is very rarely used.
     FBASE |___________________|
           |                   |  <-- your stack grows down from here
           |        CCP        |
     CBASE |___________________|  You can overwrite CCP if you want
           |                   |  (But end with warm boot if so)
           |                   |
           |                   |
           |        TPA        |
           |                   |
           |                   |
     0100h |___________________|  <-- program loaded in here
           |                   |
           | SYSTEM PARAMETERS |  More about this below
           |___________________|
     0000h

This is the usual layout for CP/M 2.2. CP/M 3 (or "+") can use a
different memory bank to hold most of the BDOS and BIOS, to give a
larger TPA. To your program though, it'll look much the same.

The BDOS is what you'll call to do most things - output text, get
input, read/write files, etc. The BIOS provides some very low-level
services which the BDOS uses. The CCP is the `shell' - basically, it
reads in the command line and loads/executes the relevant command.

Note that if you overwrite the CCP, you MUST jump to 0000h to exit the
program rather than using a RET. This causes a `warm boot' which
reloads the CCP on those systems which require it.

FBASE is the address at 0006h. CBASE is FBASE-0806H.

NB: You should assume that *all* systems have a separate CCP when
deciding whether you need to do a warm boot or not. This way, your
program will run correctly on all CP/M systems. The best policy is
this: if in doubt, do a warm boot.

(If you're wondering why some CP/M-like systems have a separate CCP
and some don't - well, that's a good question. :-))


A word about the stack - CP/M 2.2 only allowed for six words of stack
space before starting to overwrite the CCP (!), and if you use any
more you must exit using a warm boot. Given that this much stack use
is a virtual certainty, programs targeting generic CP/M should
probably either always exit via warm boot, or be very careful how they
save/restore SP, and set up a custom SP based on the TPA size (while
leaving room for the CCP).


##   The Zero Page

The `system parameters' section, or the `zero page', is the most
important from a programming point of view. The significant things in
this are:

```
0000h - `JP 0' does a warm boot
0005h - `CALL 5' calls the BDOS
005Ch - an FCB constructed from the 1st arg
006Ch - an FCB constructed from the 2nd arg
0080h - length of command tail in bytes
0081h - command tail
```

(FCBs are explained below.)

The `command tail' is the command line minus the actual command name -
so if you type `ted foo.txt' the command tail would be ` foo.txt'.
Yes, it even includes any spaces you type after the command name - if
you put two spaces between `ted' and `foo.txt' there would be two
spaces at the start of the command tail.

The command tail is always forced to be all-caps by the CCP, so watch
out for that.


##   File Control Blocks (FCBs)

FCBs are the closest thing CP/M has to file handles. They contain the
filename, current position in the file, and other such information.
They're used extensively by the BDOS for file operations, so it's
important to know what they are and how they work.

(ZCN users might also want to look at `stdio.z' in zcnlib, which
provides a much nicer way to read/write files, modelled after C's
stdio. It's described later on.)

The usual 33-byte FCB, used for reading files sequentially, is:

```
Offset	Name	Length	Description
------	----	------	-----------

0	DR	1	Drive the file is on
1	F1-F8	8	Filename - the part before the `.'
9	T1-T3	3	Extension (or `filetype') - the part after
12	EX	1	Current extent
13	S1-S2	2	For internal system use
15	RC	1	System use; number of records in extent EX
16	D0-DN	16	For internal system use
32	CR	1	Current record in extent EX
```
For random-access to be possible, you need a 36-byte FCB which
includes these:
```
33	R0-R2	3	Random-access record number (little-endian)
```
The `name' column contains the abbreviated names for each field.

DR is 0 for `current drive', 1 for A:, 2 for B:, etc.

F1-F8 and T1-T3 constitute the filename. To give an example; the
filename `wibble.com' would have F1-F8 as "WIBBLE__" and T1-T3 as
"COM", where the two underscores represent spaces.

[The FCBs provided by the system at 005Ch and 006Ch have DR and
F1-F8/T1-T3 already filled in with the file details in the 1st and 2nd
args in the command tail. The one at 005Ch can be used as is, but if
you want to use the one at 006Ch, it must be copied somewhere else
before using either.]

EX should be in the range 0-31 inclusive. It should be set to zero
before any file operations. It represents which 16k section of the
file is currently being addressed. (0 is the 1st 16k, 1 the 2nd, etc.)

CR should be in the range 0-127 inclusive. It should also be set to
zero before any file operations. It points to the current record in
the extent EX. A record is always 128 bytes long - this is the only
unit you can read and write in CP/M.

The BDOS sequential read/write functions update CR and EX to point to
the next record automatically, so once you've zeroed them out and
opened/created the file you can forget about them. The maximum file
size you can read/write with sequential file operations is 512k.

R0/R1/R2 take over the role of EX and CR when you use random-access on
a file. The usual way to use these is to zero R0/R1/R2 before any file
operations and then just use R0/R1 as a 16-bit record address, with R0
the least significant. Note that the BDOS random-access functions do
NOT update R0/R1/R2 to point to the next record - if you want this,
you must do it yourself. The maximum file size you can read/write with
random-access file operations using R0/R1 is 8192k (8MB).


##   The `DMA'

The DMA is a 128-byte buffer which read/write operations use to read
to or write from. The DMA is also used by some other BDOS functions
such as `search for first'. Its address is initially 0080h, but this
can be changed with a BDOS call.

Note that 0080h clashes with the command tail, so you must either read
that or relocate the DMA before any operations which modify the DMA.


##   User numbers

[This section is adapted from the `zselx' README. It's here for those
not sufficiently familiar with CP/M to know what user numbers are.]

The term `user' in this file means `user area' or `user number'. If
you don't know what that means, check your CP/M manual. They're a
little bit like directories on other OS's. For those people without a
CP/M manual, here's the definition from the CP/M 2.2 manual:

"user number: Number assigned to files in the disk directory so that
different users need only deal with their own files and have their own
directories, even though they are all working from the same disk. In
CP/M, files can be divided into 16 user groups."

On a single-user system, then, they can be used rather like
directories. They're numbered from 0 to 15, with 0 the default user.

(You can use the `user n' command to switch to user n.)


##  BDOS functions

You call the BDOS with `CALL 5'. Before doing this however, you need
to specify the BDOS function number, args, etc. in the relevant
registers. The list of BDOS functions below should tell you what you
need to know. Note that all of AF/BC/DE/HL are liable to be corrupted
on exit, except where stated otherwise. (A register which `corrupts'
is one modified by the function which is not returning a result, and
which does not have its previous value restored.) IX/IY, the high bit
of R, and the alternate register set (AF', BC', DE', and HL') will
always remain intact, as CP/M is written in 8080 which didn't have
these, and even Z80 CP/M or BDOS clones conform to these requirements.
(The BIOS may need to use I, however.)

There are several different BDOS functions, described below. The
descriptions are written as though instructing the BDOS what to do
when the function is called. Sorry if this looks a little odd.

Only CP/M 2.2 functions are described, except for functions 3/4/7/8
which have different effects on CP/M 2.2 and 3. (Another exception is
function 46, which I considered useful enough to include for CP/M 3
and ZCN users.)

Note that those functions which support wildcards only support the `?'
wildcard, not the `*' one. The FCBs provided by the system have any
`*'s converted - this is the only place in CP/M where the `*' wildcard
is actually recognised!

(NB: ZCN allows `*' in wildcards everywhere, but you probably
shouldn't depend on this behaviour unless your program is
ZCN-specific.)

```
0 - System Reset
entry: C=0
exit:  none (doesn't return)

Warm boot. Same effect as `JP 0'.


1 - Console Input
entry: C=1
exit:  A=char pressed

Wait until a key is pressed, echo it, and return the ASCII value in A.


2 - Console Output
entry: C=2, E=char to output
exit:  none

Output char in E.


3 - Reader Input
entry: C=3
exit:  A=char read

Read a char from the reader device. Wait until a char is ready before
returning. On CP/M 3, read from AUX:. On ZCN, read from the serial
port.


4 - Punch Output
entry: C=4, E=char to output
exit:  none

Send char in E to punch device. On CP/M 3, send to AUX:. On ZCN, send
to the serial port.


5 - List Output
entry: C=5, E=char to output
exit:  none

Print char in E.


6 - Direct Console I/O
entry: C=6, E=FFh (for input) or char to output
exit:  if E was FFh; A=0 if no char ready, else A=char input

If E isn't FFh, output char in E to console. Otherwise, return A=0 if
no char is waiting to be read, or A=char input. This function is the
only way to get input without echo via the BDOS.

The CP/M 2.2 manual says "Function 6 must not be used in conjunction
with other console I/O functions". Mixing the two can genuinely cause
problems on some CP/M configurations, so it's worth bearing in mind.
It's not a problem on ZCN though.


[Functions 7 and 8 have different meanings in CP/M 2.2 and 3.]

7 - CP/M 2.2: Get I/O Byte; CP/M 3 and ZCN: AUX:/serial input status
entry: C=7

CP/M 2.2: Return A=IOBYTE.
CP/M 3 and ZCN: Return A=0 if no chars waiting, else A=FFh.


8 - CP/M 2.2: Set I/O Byte; CP/M 3 and ZCN: AUX:/serial output status
entry: C=8

CP/M 2.2: Set IOBYTE=E.
CP/M 3 and ZCN: Return A=0 if can't write now, else A=FFh.


9 - Print String
entry: C=9, DE=string address
exit:  none

Output string at DE to console. The string is terminated by a `$'
character. There is no way of outputting a literal `$' character with
this function.


10 - Read Console Buffer
entry: C=10, DE=buffer address
exit:  none

Read a string from console into buffer at DE. The buffer has this
format:

	DE+0 - entry: max number of chars to allow at DE+2
	DE+1 - exit:  number of chars following
	DE+2 - exit:  string starts here

The string is not terminated by any character, and the CR typed at the
console to terminate input is omitted. The string is output as it is
typed in, *including the CR*.


11 - Get Console Status
entry: C=11
exit:  A=0 if no char ready, else A=FFh

Return A=0 if no char ready, else return A=FFh.


12 - Return Version Number
entry: C=12
exit:  HL=version

Return H=0 (for CP/M, as opposed to MP/M where it returns H=1) and L
equals 0 for CP/M 1.x, else the version number in BCD. For example,
CP/M 2.2 returns L=22h.

To find a ZCN version number is a little more complicated, as ZCN
pretends to be CP/M 2.2 as far as this function is concerned. See the
`ZCN' section below for details.


13 - Reset Disk System
entry: C=13
exit:  none

Set all disks to read/write, make drive A: current, set DMA address to
0080h. You *must* do this after a disk is changed (this can only apply
to removeable media like floppies, of course) before accessing it, or
corruption can result.

(Corruption is unlikely, as most drives can detect disk changes, which
CP/M then notices and makes the disk read-only which this call resets;
however, it *is* a possibility on some systems.)

This call is unnecessary on ZCN, but you *must* use it after any
disk-swapping activity to have the slightest chance of your program
working on other CP/M systems.


14 - Select Disk
entry: C=14, E=drive
exit:  none

Set current drive to value in E, where E=0 for A:, 1 for B:, etc.


15 - Open File
entry: C=15, DE=FCB address
exit:  A=directory code

Open existing file for reading. Return A in range 0 to 3 inclusive if
it worked, else A=FFh, usually meaning `file not found'.


16 - Close File
entry: C=16, DE=FCB address
exit:  A=directory code

Close file. (You don't need to do this if you only read from it.)
Return A in range 0 to 3 inclusive if it worked, else A=FFh.

The CP/M 2.2 manual says the file "need not be closed" if it was only
read from. Not closing such files saves doing an unnecessary write to
the directory area, so it's common practice. However, it is *vital* to
correctly close files you wrote to. (ZCN is an unusual case - its file
I/O is stateless, and you never need to close files. It's a bad idea
to depend on this, though.)


17 - Search For First
entry: C=17, DE=FCB address
exit:  A=directory code

Search for the first file matching the drive/name in the FCB, which
may contain a wildcard (and usually will). Return A in range 0 to 3
inclusive if a file matched, else A=FFh. If a file matched, the
matching directory entry is put at dma_address+32*A. The format of a
directory entry is difficult to describe without having to describe
the entire CP/M disk format - suffice it to say that the filename is
at offsets 1 to 11 inclusive, the same as an FCB, and that the top bit
of each may be set to indicate a file attribute (see the `set file
attributes' description for what they mean).

If this call succeeds, you should then call the `search for next'
function to read any other matching filenames.

The wildcards supported by this call are slightly more flexible than
in the rest of CP/M, and deserve special mention:

As well as allowing `?' in the filename to match any possible char at
that position, this function allows the `dr' field to be a `?', which
matches (confusingly) any user number. In that case, the byte at
offset 0 in the dir entry is the user number; if `dr' isn't `?', then
the byte contains the drive number, again the same as an FCB.

The other wildcard extension allowed by this function is that if `ex'
contains a `?', all extents of the file are considered to match,
rather than just the 0th. This can be used to work out the size of
each file as you go through the files, but that's outside the scope of
this document.


18 - Search For Next
entry: C=18
exit:  A=directory code

Find the next file matching the FCB passed to `search for first'.
Return A in range 0 to 3 inclusive if a file matched, else A=FFh. This
function also puts a dir. entry at dma_address+32*A if successful.

The most recent BDOS call before calling this function *must* have
been either `search for first' or a previous `search for next'.


19 - Delete File
entry: C=19, DE=FCB address
exit:  A=directory code

Delete any files matching the FCB (you can use wildcards). Return A in
range 0 to 3 inclusive if it worked, else A=FFh.


20 - Read Sequential
entry: C=20, DE=FCB address
exit:  A=directory code

Read a record from the file and advance cr (and ex if needed). Return
A=0 if it worked, else A>0.


21 - Write Sequential
entry: C=21, DE=FCB address
exit:  A=directory code

Write a record to the file and advance cr (and ex if needed). Return
A=0 if it worked, else A>0. Failure usually means that either the disk
is full, or the directory is (i.e. no more dir. entries are left).


22 - Make File
entry: C=22, DE=FCB address
exit:  A=directory code

Create new file for writing to. Return A in range 0 to 3 inclusive if
it worked, else A=FFh. Failure usually means that no more dir. entries
are left.

Be warned that the results of creating a file with the same name as a
file which already exists are undefined! (This is techspeak for "you
don't *want* to know what the results are, just don't do it...".) To
create a file deleting any existing file of the same name first,
simply attempt to delete the file you want to open before creating the
new file. It doesn't matter whether the deletion worked or not - if it
worked, the existing file was deleted, if it didn't, there wasn't one
to delete anyway!

(Under ZCN this is what actually happens when you call the `make file'
function itself; but this is mind-bogglingly non-standard and you
should not depend on this behaviour, at all, ever. Really. I mean it.)

You don't have to subsequently open the file created with this
function before writing to it; it's automatically opened.


23 - Rename File
entry: C=23, DE=FCB address
exit:  A=directory code

Rename the file specified in the first 16 bytes of the FCB to the name
specified in the second 16 bytes of the FCB. (The 2nd 16 bytes should
be in the format of bytes 0..15 of a normal FCB.) Return A in range 0
to 3 inclusive if it worked, else A=FFh.


24 - Return Login Vector
entry: C=24
exit:  HL=login vector

Return login vector in hl. Bit 0 of L corresponds to A: and bit 7 of
H to P:.

The login vector is a bitmap indicating which drives have been
accessed and have valid buffer info etc. - if a given drive has/does,
the relevant bit will be 1, else 0. For the drive to count as having
been accessed you need not have read anything from it, but simply have
to have selected the drive since the last warm boot or reset.

It then follows that one way to get a login vector which shows which
drives exist on the system is to select all drives from A: to P: in
succession, then call this function. The returned bitmap should
indicate which drives are valid. (Note: I haven't actually *tested*
this, but it seems reasonable.)


25 - Return Current Disk
entry: C=25
exit:  A=current disk number

Return current default disk in A, with 0=A:, 1=B:, etc.


26 - Set DMA Address
entry: C=26, DE=128-byte area of memory to use as DMA buffer
exit:  none

Set address of DMA buffer (used mainly for read/write ops) to DE.


27 - Get Addr (Alloc)
entry: C=27
exit:  HL=alloc addr

Return address of allocation `vector' in HL.

(What this means is complicated, so I'll quote the CP/M 2.2 manual:)

"An allocation vector is maintained in main memory for each on-line
disk drive. Various system programs use the information provided by
the allocation vector to determine the amount of remaining storage...
Function 27 returns the base address of the allocation vector for the
currently selected disk drive. However, the allocation information
might be invalid if the selected disk has been marked Read-Only."

It further notes that the function is "not normally used by
application programs". If it *is* used, it tends to be used to work
out the free disk space. (This is distinctly unpleasant, and how it's
done will not be described here.) On CP/M 3 and ZCN, function 46 is a
better way of doing this.

I don't think this function returns meaningful results with CP/M 3, or
at least not with certain versions of it. It certainly doesn't return
anything meaningful under ZCN, which is very different to CP/M
internally and doesn't use (or need) the allocation stuff.


28 - Write Protect Disk
entry: C=28
exit:  none

Disallow further write operations on current disk until warm boot or a
call to `reset disk system'.

If you use this function, do not assume that it will definitely work -
there are some CP/M-like systems on which it won't. It's probably best
to not use it at all.


29 - Get R/O Vector
entry: C=29
exit:  HL=R/O bitmap

Return R/O bitmap in HL. This is in the same format as that returned
by `return login vector', except it indicates which drives are
read-only.


30 - Set File Attributes
entry: C=30, DE=FCB address
exit:  A=directory code

Set the file's attributes based on the top bits of the filename. The
top bits of T1 and T2 are used respectively to set `read-only' and
`system' status for the file. The other top bits of the filename may
be used too - those for T3 and F5-F8 are reserved, but the F1-F4 bits
may be used by programs for whatever purpose they want. (However, T3's
top bit is used as the `archive' attribute on CP/M 3.)

ZCN does not support file attributes (mainly due to the problem with
0066h), and this call will have no effect other than claiming to have
succeeded.


31 - Get Addr (Disk Parms)
entry: C=31
exit:  HL=address of DPB

Return the address of the BIOS disk parameter block in hl. Again, ZCN
will not return meaningful results. What the DPB is will not be
described here. The 2.2 manual says "Normally, application programs
will not require this facility".


32 - Set/Get User Code
entry: C=32, E=FFh (for `get') or user number to make current
exit:  if E=FFh, A=current user number; else none

If E=FFh, return current user number in A, else set current user
number to E.


33 - Read Random
entry: C=33, DE=FCB address
exit:  A=error code

Read record pointed to by r0/r1/r2. Return A=0 if it worked, else A>0.
Unlike the sequential function, this does not advance the file pointer
(r0/r1/r2 in this case).

Note that this function only really uses r0/r1 - r2 is largely ignored
but must be zero.

This function also converts the current r0/r1 value to a sequential
file pointer and puts this in cr/ex, but I would *STRONGLY* advise not
relying on this, and not mixing random and sequential operations on
the same file. For one thing, sequential ops only support far smaller
files (512k rather than 8MB), so `interesting' corruption could
result for large files.

Possible error codes returned in A when it's non-zero are:

1	reading unwritten data
3	cannot close current extent
4	seek to unwritten extent
6	seek past physical end of disk


34 - Write Random
entry: C=34, DE=FCB address
exit:  A=error code

Write record pointed to by r0/r1/r2. Return A=0 if it worked, else
A>0. Unlike the sequential function, this does not advance the file
pointer (r0/r1/r2 in this case).

Note that this function only really uses r0/r1 - r2 is largely ignored
but must be zero.

This function also converts the current r0/r1 value to a sequential
file pointer and puts this in cr/ex, but I would *STRONGLY* advise not
relying on this, and not mixing random and sequential operations on
the same file. For one thing, sequential ops only support far smaller
files (512k rather than 8MB), so `interesting' corruption could
result for large files.

Possible error codes returned in A when it's non-zero are:

1	reading unwritten data
3	cannot close current extent
4	seek to unwritten extent
5	file cannot be extended
6	seek past physical end of disk


35 - Compute File Size
entry: C=35, DE=FCB address
exit:  none (but r0/r1/r2 altered)

Return size of file in r0/r1/r2. The size is in records, and r0 is the
least significant byte.

Note that as well as being useful for directory listing programs etc.,
this function provides a nice easy way to append to an existing file
using `write random' after r0/r1/r2 are set.

On some CP/M systems, the file must be opened before calling this
function. However, no mention of this is made in the 2.2 manual, and
it only happens on one system I know of - a CP/M emulator - so I
reckon it's just a bug in that emulator.


36 - Set Random Record
entry: C=36, DE=FCB address
exit:  none (but r0/r1/r2 altered)

Set random-access position in r0/r1/r2 from current sequential file
position in cr/ex.


37 - Reset Drive
entry: C=37, DE=drive bitmap
exit:  A=0 (the 2.2 manual says this is "to maintain compatibility with MP/M")

Reset drives flagged in bitmap. The bitmap is in the same format as
that returned by `return login vector', except it indicates which
drives to reset.


[Functions 38 and 39 are undefined under CP/M 2.2.]


40 - Write Random with Zero Fill
entry: C=40, DE=FCB address
exit:  A=error code

Like `write random', but fills unwritten areas which have been
allocated to the file with zeroes.

On ZCN, this is identical to `write random' - that is, it doesn't
actually do the zero fill.


[Functions >=41 are undefined under CP/M 2.2.]


46 - Get Free Disk Space (CP/M 3 and ZCN only)
entry: E=drive number (0=A:, 1=B:, etc.)
exit:  none (but dma_address+0 to dma_address+2 = number of free records)

Return free disk space in records, in 3-byte number at DMA address.
The byte at offset 0 in the DMA is the least significant.
```

##   MP/M? What's that?

MP/M is mentioned a couple of times above, so I thought it reasonable
to give a quick description. To quote the manual, MP/M supported
"multi-terminal access with multi-programming at each terminal". So,
quite different to CP/M, but it could run some CP/M programs.


##  Processor issues - writing 8080-compatible code in Z80

CP/M is designed to run on an Intel 8080 CPU. Now, Z80s can run 8080
code, so that's not a problem. But every time you write a CP/M program
in Z80, you risk it not running on 8080s, 8085s, and even V20/V30s
(which usually run as 8086-compatibles but can also run 8080 code).

Since all of these can run CP/M, you may want to write a program in
Z80 but still let it run on 8080s etc. This is perfectly possible, as
the Z80 instruction set is simply an extension of the 8080 one. You
have to give up quite a lot of useful stuff though.

If you really do want your code to run on an 8080, you have to avoid
using the alternate register set and IX/IY/I/R (which don't exist on
the 8080), and avoid all these instructions:

- ldir/lddr and all similar block ops
- djnz and all other relative jumps
- ld rr,(nn) and ld (nn),rr for rr=bc,de,sp (hl is ok)
- neg
- all 16-bit adc/sbc ops (yep, no 16-bit subtraction on an 8080)
- all bit-shift ops except rla/rra/rlca/rrca
- all bit/set/res ops

To do 16-bit subtraction, you could two's complement the number you
want to subtract (invert the bits and add one) then add it. This is
pretty painful and slow, but it works. One problem with it is that it
doesn't give sbc-like flag results. Doing it with 8-bit subtractions
fixes that, and is probably quicker anyway. To give an example of the
latter, this code should be exactly equivalent to `sbc hl,de' (apart
from needing to use the stack :-)) and work on an 8080:
```
push de
push af

ld a,l
sbc a,e
ld l,a
ld a,h
sbc a,d
ld h,a

pop de
ld a,d
pop de
```
You can omit the weird push/pop stuff if you don't care about A
getting clobbered.

There are a few more `missing' instructions which shouldn't matter for
generic CP/M code. But for the sake of completeness, I'll list those
too:

- reti/retn
- in and out r,(c) for all r
- im 0/im 1/im 2

Looking at it another way, here's the 8080 instruction set using Z80
mnemonics:
```
00      nop
01      ld bc,NN
02      ld (bc),a
03      inc bc
04      inc b
05      dec b
06      ld b,N
07      rlca
08      
09      add hl,bc
0A      ld a,(bc)
0B      dec bc
0C      inc c
0D      dec c
0E      ld c,N
0F      rrca
10      
11      ld de,NN
12      ld (de),a
13      inc de
14      inc d
15      dec d
16      ld d,N
17      rla
18      
19      add hl,de
1A      ld a,(de)
1B      dec de
1C      inc e
1D      dec e
1E      ld e,N
1F      rra
20      
21      ld hl,NN
22      ld (NN),hl
23      inc hl
24      inc h
25      dec h
26      ld h,N
27      daa
28      
29      add hl,hl
2A      ld hl,(NN)
2B      dec hl
2C      inc l
2D      dec l
2E      ld l,N
2F      cpl
30      
31      ld sp,NN
32      ld (NN),a
33      inc sp
34      inc (hl)
35      dec (hl)
36      ld (hl),N
37      scf
38      
39      add hl,sp
3A      ld a,(NN)
3B      dec sp
3C      inc a
3D      dec a
3E      ld a,N
3F      ccf
40      ld b,b
41      ld b,c
42      ld b,d
43      ld b,e
44      ld b,h
45      ld b,l
46      ld b,(hl)
47      ld b,a
48      ld c,b
49      ld c,c
4A      ld c,d
4B      ld c,e
4C      ld c,h
4D      ld c,l
4E      ld c,(hl)
4F      ld c,a
50      ld d,b
51      ld d,c
52      ld d,d
53      ld d,e
54      ld d,h
55      ld d,l
56      ld d,(hl)
57      ld d,a
58      ld e,b
59      ld e,c
5A      ld e,d
5B      ld e,e
5C      ld e,h
5D      ld e,l
5E      ld e,(hl)
5F      ld e,a
60      ld h,b
61      ld h,c
62      ld h,d
63      ld h,e
64      ld h,h
65      ld h,l
66      ld h,(hl)
67      ld h,a
68      ld l,b
69      ld l,c
6A      ld l,d
6B      ld l,e
6C      ld l,h
6D      ld l,l
6E      ld l,(hl)
6F      ld l,a
70      ld (hl),b
71      ld (hl),c
72      ld (hl),d
73      ld (hl),e
74      ld (hl),h
75      ld (hl),l
76      halt
77      ld (hl),a
78      ld a,b
79      ld a,c
7A      ld a,d
7B      ld a,e
7C      ld a,h
7D      ld a,l
7E      ld a,(hl)
7F      ld a,a
80      add a,b
81      add a,c
82      add a,d
83      add a,e
84      add a,h
85      add a,l
86      add a,(hl)
87      add a,a
88      adc a,b
89      adc a,c
8A      adc a,d
8B      adc a,e
8C      adc a,h
8D      adc a,l
8E      adc a,(hl)
8F      adc a,a
90      sub b
91      sub c
92      sub d
93      sub e
94      sub h
95      sub l
96      sub (hl)
97      sub a
98      sbc a,b
99      sbc a,c
9A      sbc a,d
9B      sbc a,e
9C      sbc a,h
9D      sbc a,l
9E      sbc a,(hl)
9F      sbc a,a
A0      and b
A1      and c
A2      and d
A3      and e
A4      and h
A5      and l
A6      and (hl)
A7      and a
A8      xor b
A9      xor c
AA      xor d
AB      xor e
AC      xor h
AD      xor l
AE      xor (hl)
AF      xor a
B0      or b
B1      or c
B2      or d
B3      or e
B4      or h
B5      or l
B6      or (hl)
B7      or a
B8      cp b
B9      cp c
BA      cp d
BB      cp e
BC      cp h
BD      cp l
BE      cp (hl)
BF      cp a
C0      ret nz
C1      pop bc
C2      jp nz,NN
C3      jp NN
C4      call nz,NN
C5      push bc
C6      add a,N
C7      rst 0
C8      ret z
C9      ret
CA      jp z,NN
CB
CC      call z,NN
CD      call NN
CE      adc a,N
CF      rst 8
D0      ret nc
D1      pop de
D2      jp nc,NN
D3      out (N),a
D4      call nc,NN
D5      push de
D6      sub N
D7      rst 16
D8      ret c
D9      
DA      jp c,NN
DB      in a,(N)
DC      call c,NN
DD
DE      sbc a,N
DF      rst 24
E0      ret po
E1      pop hl
E2      jp po,NN
E3      ex (sp),hl
E4      call po,NN
E5      push hl
E6      and N
E7      rst 32
E8      ret pe
E9      jp (hl)
EA      jp pe,NN
EB      ex de,hl
EC      call pe,NN
ED
EE      xor N
EF      rst 40
F0      ret p
F1      pop af
F2      jp p,NN
F3      di
F4      call p,NN
F5      push af
F6      or N
F7      rst 48
F8      ret m
F9      ld sp,hl
FA      jp m,NN
FB      ei
FC      call m,NN
FD
FE      cp N
FF      rst 56
```

As for whether you should go to the trouble of making your code
8080-friendly - well, it depends. There haven't been many popular
8080-based CP/M boxes in the UK, so my biased view is that it's not
usually worth the hassle. :-)

It should be possible to write a filter which converts normal Z80
assembly to 8080-compatible Z80 assembly. That would certainly be a
better way of doing things. (Though you'd still have to avoid IX/IY,
etc.) I've written such a filter in awk, called z8080, but since I
don't have an 8080-based machine to test the output on I can't be
certain how well it works. It does seem to work well enough on
emulators though. (If you're reading this as part of the ZCN
distribution, a copy is included - see `z8080.txt' for details.)


# ZCN

##  What the NCs have that generic CP/M machines don't

Essentially, the NC100/NC150/NC200 all have graphics, sound, a fully
readable keyboard, memory paging hardware, and a real-time clock. See
`zcn.txt' for details of the first three. The memory paging is
described later in this file. The RTC's time/date can be read/written
via ZCN-specific BDOS functions, also described later on.


##  Testing for ZCN

You should not use ANY NC-specific or ZCN-specific features without
first testing that you're running under ZCN. The easiest way to do
this is to check, right at the start of the program, that the value at
0066h is F7h. If it is, you're either running ZCN, or a fork like
CP/NC. Ideally you should then use BDOS function 128 (ZCN version
number) - if that returns A=FFh then you're not running on ZCN. This
is, as I semi-jokingly like to put it, a "better ZCN check". :-)

For a completely ZCN-specific program which would not work at all
under generic CP/M, it's reasonable to simply die if ZCN isn't
present, like this:

	ld a,(066h)
	cp 0f7h
	jp nz,0		(or just "ret nz" if the stack is `empty')

You may wish to be a bit less brutal about it and output an error
message, though.


##  The memory paging hardware

The NC100 pages memory in 16k pages, with the 64k address space making
up 4 slots into which any part of RAM, ROM or PCMCIA card memory can
be paged. (A PCMCIA memory card is just memory, after all, even if ZCN
solely uses it as a disk - with the exceptions of `bigrun' and booting
from card.) The NC200 and NC150 have 128k of RAM, but work in the same
way.

Memory is paged by OUTing to port 10h for the 0000-3FFFh slot, 11h for
the 4000-7FFFh slot, 12h for the 8000-BFFFh slot, and 13h for the
C000-FFFFh slot. The values to OUT depend on the type of memory and
which 16k page is to be paged in. The low six bits of the value are
the 16k page number, with 0 being the first 16k, 1 the next, etc. The
top two bits should match the type of memory being used - 00b for ROM,
01b for RAM, or 10b for PCMCIA memory.

So, for example, to page the first 16k of PCMCIA memory into the
4000-7FFFh slot, you'd use:

	ld a,080h
	out (011h),a

ZCN does something similar to this to read/write files on the `disk',
though this is obviously transparent to your program.

I'd recommend not using the memory paging hardware unless you REALLY
have to. It's sooo easy to swap out an interrupt routine, the stack,
your code... and with a one-bit error you could even corrupt your
memory card! And don't forget that whatever you've paged in can
`instantly' switch back to the normal RAM if the machine is turned off
and on after your paging operation. (ZCN protects against this for
paging operations *it* does, but your program can't.)

[Well... that isn't strictly true. If you check ZCN's src/start.z, you
can see that the "bank1" variable is in an easily-calculated location,
and this is deliberate - it's been there since ZCN 0.1. See the source
to `bigv' for an example of how you can use it in a program.]

If you really do want to use paging for some reason, be sure to only
use 4000-7FFFh. 0000-3FFFh contains the NMI routine (well, the jump to
the real routine at least), and 8000-BFFFh and C000-FFFFh between them
contain all of ZCN.


##  ZCN-specific BDOS functions

There are several BDOS functions specific to ZCN. These are listed
here. Many of these were quick single-purpose hacks so I could support
something in a user program rather than having to add another internal
command, so don't be surprised if some of them seem rather strange.

NB: These should only be used after doing the tests mentioned in the
"Testing for ZCN" section above (except for function 128, which you
can safely use after just the 0066h test).

```
128 - ZCN version number
entry: C=128
exit:  HL=version number, A=0

Return ZCN version number in HL. This is not in the same format as the
value returned by CP/M's `return version number'! H is the major
revision number, and L is the minor. So v0.1 gave HL=0001h, and a v2.3
would give HL=0203h.

This function also acts as a more precise check that you're actually
running ZCN. It should return A=0 if so. (I believe CP/NC will
reliably return A=FFh from this.)

It's important that you don't call this without checking 0066h first,
as this BDOS function number was also used by e.g. MP/M.


129 - Set whether interrupts are `tight' or not
entry: C=129, E=1 to use tight ints or 0 for normal.
exit:  none

Set whether to use `tight' interrupts or not. The tight interrupts
mode is designed for use by games, as it's pretty awkward running the
NC with interrupts off. The big plus of TI mode is that it lets you
directly read the keyboard `bytemap' constructed by ZCN, allowing you
to read multiple keys pressed at once.

Historically, the TI mode gave a minimal interrupt too, which reduced
the interrupt burden and meant your code effectively ran faster. But
an optimisation made to ZCN since sped the normal interrupt mode up
massively, leaving the TI mode actually *slower* because of the
requirement to support multiple arbitrary keypresses at once. This
sounds perverse, but I'm afraid that's the way it has to be. See
`zcn.txt' for further details.


130 - Return address of keyboard bytemap
entry: none
exit:  HL=address of keyboard bytemap

Return the address of ZCN's keyboard bytemap. The contents are
effectively only readable in `tight ints' mode. See `zcn.txt' for
details.


131 - Return address of the 1/100th-second strobe byte
entry: none
exit:  HL=address of strobe byte

Return the address of ZCN's strobe byte. This alternates between 0 and
255 exactly 100 times a second. Note that waiting for this value to
change is NOT the same as using `halt', as `halt' waits for any
interrupt, so any serial interrupt would stop that earlier than
desired. However, for most games etc., `halt' is sufficient - the
strobe byte is largely a relic of a workaround for a problem since
solved.


132 - Return console in/out assignments
entry: none
exit:  H=input device, L=output device

Return console input/output devices in HL. H is the input device, L
the output device. The values are 0 for the normal console (the
built-in screen), 1 for the serial port, or (for output only) 2 for
the printer. (In the latter case output also appears on the screen.)

There is no way to set the redirections from user programs. Sorry.


133 - Get time from RTC
entry: DE=buffer address
exit:  none (but buffer filled)

Return the current time/date according to the real-time clock. The
buffer pointed to by de should be six bytes long. The returned buffer
is filled like this:

	de+0 de+1 de+2 de+3 de+4 de+5
	 yy   mm   dd   hh   mm   ss

The values are in BCD. The year is specified as an offset from 1990.
(Dates before 1st Jan 1990 are not supported, nor are dates after 31st
Dec 2099.) It is debatable whether this truly counts as a BCD value
for years in the range 2090-2099, as the high nibble is then 10.

Bear in mind that the clock is still running when this measurement is
taken, so to be sure of getting the true time/date you should call
this twice and use the `highest' result, i.e. the later time/date of
the two. See `time.z' for an example of how to do this.

(Note: In some situations you don't technically have to do the above,
but it's best to just always do it anyway.)


134 - Set RTC time
entry: DE=buffer address
exit:  none

Set the time/date on the real-time clock. Uses the same format buffer
as `get time from RTC'.


135 - Check drive exists and is ZCN format
entry: E=drive num. (0=current, 1=A:, etc.)
exit:  c if ok, nc otherwise

Check if drive exists and is in ZCN format.


136 - Read 128 bytes from a data block
entry: DE=table address
exit:  A=0 if ok, else 255

Read a record from a data block. Return A=0 if ok, else 255. The
format of the table is as follows:

	de+0	byte	block number (lowest being 0)
	de+1	byte	128-byte record number in block (0-7)
	de+2	byte	drive (0=A:, 1=B:, etc.)
	de+3	word	address to read 128 bytes to

You cannot read the boot block or any system blocks with this
function.


137 - Write 128 bytes to a data block
entry: DE=table address
exit:  A=0 if ok, else 255

Write a record to a data block. Return A=0 if ok, else 255. The
format of the table is as given in the description of the previous
function.

You cannot write the boot block or any system blocks with this
function.


138 - Read 128 bytes from boot block and/or system blocks
entry: DE=table address
exit:  none

Read a record from boot block and/or system blocks. (In fact, it
directly reads from anywhere in the first 16k of the logical drive.)
This routine does no error checking at all - it doesn't even check if
there's a card in the slot! The format of the table is:

	de+0	byte	drive (0=A:, 1=B:, etc.)
	de+1	word	byte offset from start of drive (0-16383)
	de+3	word	address to read 128 bytes to

Using this and the other raw read routine, it is possible to write a
routine to read any block. See the source to `zdbe' for a routine
which does this.


139 - Write 128 bytes to boot block and/or system blocks
entry: DE=table address
exit:  none

Write a record to boot block and/or system blocks. (In fact, it
directly writes to anywhere in the first 16k of the logical drive.)
This routine does no error checking at all - it doesn't even check if
there's a card in the slot! The format of the table is as given in the
description of the previous function.

Using this and the other raw write routine, it is possible to write a
routine to write any block. See the source to `zdbe' for a routine
which does this.


140 - Get bytemap of used/unused data blocks
entry: D=drive num. (0=A:, etc.)
exit:  HL=address of bytemap (where 1=unused, 0=used)

Get a bytemap of data block use for drive d. Return pointer to buffer
in HL. Some other BDOS functions use the buffer which the data is
returned in, so you should either finish using it or copy it elsewhere
before calling the BDOS again.

The bytemap doesn't include the boot block or any system blocks (which
are always used, by definition) - it only covers the data blocks. How
many data blocks there are must be worked out by looking at the boot
block (the data there is readable with function 138, and is described
in `zcn.txt'). See the source to `defrag' for how to do this.


141 - Set/unset serial port up for mouse	(requires ZCN >=0.4)
entry: E=0 for normal serial operation, non-zero for mouse,
       D=log2(baudrate/150) (e.g. 3=1200, 4=2400, 5=4800, etc.)
       (NB: D need not be specified if you're `turning off' the mouse.)
exit:  A=0 if ok, or A=FFh if unsupported (i.e. if ZCN version <0.4)

Setup the serial port for use with a Microsoft-compatible serial
mouse, or return it to normal serial operation. The mouse baud rate
etc. is stored separately from the normal one, so calling this with
E=0 to `turn off' the mouse restores all the normal serial settings,
i.e. the baud rate.

You shouldn't need to use this directly - instead, you should use the
routines in zcnlib's `mouse.z', described later.


142 - Set font base address			(requires ZCN >=1.2)
entry: DE=font base address
exit:  A=0 if ok, or A=FFh if unsupported (i.e. if ZCN version <1.2)

Sets ZCN's font base address to DE. This is where the bitmaps for the
characters printed by ZCN are held. (Though strictly speaking it's 192
bytes less, as there are no bitmaps for chars 0..31.) The displayable
chars are those in the range 32..255, with the exception of 7Fh (127)
and F7h (247). (The latter exception is to help a bit with the 0066h
problem.)

The normal font address is restored when your program exits, but you
can restore it before that (if needed) by calling this routine with
DE=EA00h.

The font is made up of N 6-byte bitmaps (ZCN itself provides 96 to
cover the ASCII character set (with the last char ignored), but up to
224 are possible), as you might expect. However, the format is
slightly unusual - for normal text output, the 4-bit-wide bitmap in
the most significant nibble must equal that in the least significant
one. (This lets ZCN display text a bit quicker.)

Interestingly though, this gives you an easy way to have double-width
graphics and the like - just treat the bitmap as 8x6, and output the
relevant char twice to get your bitmap. :-)

If you merely want to add a few graphics chars to the normal ZCN font,
just copy the ZCN font bitmaps at EAC0h down into TPA, copy your new
chars onto the end, and use that.


143 - Set user area to 255			(requires ZCN >=1.2)
entry:	none
exit:	none

It's not possible to get to user area 255 from a program, when using
the normal CP/M BDOS function for setting the user area. This function
gives you a way to do it, if you must.


144 - Check for NC200				(requires ZCN >=0.4)
entry:	none
exit:	A=0 for NC200 (zcn200.bin), otherwise A=FFh

Return machine type as above. Strictly speaking, this only tells you
which kernel is being run (zcn200.bin or another), but in practice
it's a pretty reasonable test for running on an NC200.

Before ZCN 1.4, this was incorrectly documented as testing for NC200
vs. NC100.


145 - Return address of keymaps			(requires ZCN >=1.2)
entry:	none
exit:	A=FFh if unsupported, otherwise:
	A=0,
	HL=addr of the 80-byte keymap (in start.z),
	DE=addr of the two 22-byte shift-mapping tables (in keyread.z)

Return the addresses of ZCN's key mapping tables. This function is
really just for `keyb' - don't mess with the tables unless you know
what you're doing. :-)

(As of ZCN 1.4, there are actually further tables placed immediately
after the shift-mapping tables. Symbol mapping in two 15-byte tables,
and dead key mapping in four 11-byte tables.)


146 - Check for NC150				(requires ZCN >=0.4)
entry:	none
exit:	A=0 for NC150 (zcn150.bin), otherwise A=FFh

Return machine type as above. Again, strictly speaking this only tells
you which kernel is being run (in this case, zcn150.bin or another).
This is a less reliable test for the NC150 than the NC200 one above,
just because the NC150 is far happier running zcn.bin than the NC200
is, but it's probably about the best you can do short of digging
around in the ROM or doing fiddly hardware testing like `nctest' does.

This is a separate function rather than being folded into function 144
in the hope of not breaking existing programs, which might quite
reasonably be testing that as a simple on/off switch.
```

##  Using ZCN's zcnlib library

I wrote ZCN as a CP/M clone. That's fine as far as it goes, but CP/M
is a bit primitive. I eventually decided that I'd like a higher-level
interface to ZCN. With the limited memory available, I opted to
write a library of useful routines rather than a new system-call
interface, and zcnlib was the result.

Zcnlib is public domain, and you can do anything you want with it. See
the zcnlib README for details. It consists of various source files,
each of which covers some abstract task, e.g. graphics drawing, file
I/O, etc. The routines in each are described here. The routines in
some files require routines in other files - these dependancies, where
they exist, are noted at the start of the description of the file.

Though they're intended for use on ZCN only, most of the more generic
routines should work on any Z80-based CP/M box, and the really generic
ones (maths etc.) should work on *any* Z80-based system. (That's
excluding pathological cases like the ZX81, where you can't reasonably
use IX, IY or the alternate register set, which would render (say) the
32-bit int routines unusable.)

Before I start describing the routines, there are several things you
should be aware of:

- In entry/exit conditions, capital letters represent registers, while
lowercase ones represent flag status. For example, `C' is the C
register, while `c' is the carry flag. In descriptions, I tend to use
lowercase for everything and let context resolve ambiguities.

- Sometimes I may say that a certain flag has a certain value on exit
from a routine, but then go on to say that F (the flags register)
corrupts. What I mean in this case is that flags not specified as
having a meaningful value corrupt. In all other cases, if I say a
register corrupts I really mean it. :-)

- All registers which don't return values, and which don't corrupt,
aren't touched by the routine and are preserved. Sometimes I mention
this explicitly, to make it clear which registers remain intact.

- Following on from the above, most routines preserve IY and the
alternate register set. Here is a (hopefully exhaustive) list of
exceptions:
  - in graph.z - ftri corrupts IY. 
  - in int32.z - mul32/smul32/div32/sdiv32 and the number I/O routines
                  corrupt IY and all alternates except AF'.

   Quite a few routines also preserve IX. Here's a list of exceptions to
   that:

  -   in args.z - makeargv.
  -  in graph.z - draw8x8, save16x8, rstr8x8.
  -  in graph2.z - ftri.
  -  in int32.z - all routines.
  -  in mouse.z - mouseon, mouseoff, mstat.
  -  in qsort.z - qsort uses IX as addr of compare routine.
  -  in sqrt.z - intsqrt.
  -  in stdio.z - all routines.

- An `asciiz' string (these are used by some routines) is zero or more
ASCII characters followed by a zero byte - that is, a NUL, a byte with
all bits zero.


Covering the source files in alphabetical order:


##   args.z

A clone of C's argc/argv. Requires string and ctype. In case you're
not familiar with C, here's an example. Take the command-line:

	foo bar baz

(`foo' is the command, `bar' and `baz' are args.)

Here, argc is 3, and there are three elements in the argv array -
argv[0] is "foo", argv[1] is "bar", argv[2] is "baz". (In CP/M, there
is no way of knowing the way the command was run, so argv[0] will
really be "", the null string. Also, the cmdline is lowercased from
the all-caps copy the system provides.)

To use this argc/argv method of reading the command-line (well,
command tail) you call `makeargv' as early as possible in your
program. Then you can read the byte at `argc' (you can read this as a
word if that's more convenient) and the `argv' array - the routine
`getargv' returns hl=argv[a]. As you might expect, the strings in the
argv array are asciiz.

```
makeargv
entry: none (but cmdline at 80h-ffh must be intact)
exit:  AF/BC/DE/HL/IX corrupt, cmdline corrupt

Assign correct values to argc/argv based on command tail at 0080h.
After calling this routine, you can do whatever you want with the data
at 0080-00FFh, argc/argv aren't affected.

There is no way of `quoting' arguments, i.e. to put one or more spaces
in an argument. Spaces always separate arguments, no matter what.


getargv
entry: A=argv element to look up
exit:  HL=addr of argv[A], all other registers preserved

Return the address of the specified element of the argv array.
```

##   conio.z

Console I/O routines, many similar to those in DOS C compilers (or
rather, the libraries that come with them).

```
putchar
entry: A=char to output
exit:  F corrupt

Output char in A. If A=10 (LF), this is converted to CR/LF.


putbyte
entry: A=char to output
exit:  F corrupt

As for `putchar', but doesn't translate LF into CR/LF.


getchar (and getch)
entry: none
exit:  A=char input, F corrupt

Input char into A. It waits until a key is pressed, and does not echo
it. (Also, it doesn't translate the char at all, which is unexpected
when compared with putchar, but is probably what you want.)


kbhit
entry: none
exit:  c if key pressed, nc if not; AF/BC/DE/HL corrupt

Report if any key is waiting to be read, but do not read it. This is
similar to the common DOS C function.
```

##   ctype.z

Clones of C's `ctype' routines for testing if a char is upper/lower
case, etc.

These routines work in the sanest possible way - i.e. the `toupper'
only tries to uppercase lowercase chars. If you're thinking, "well
what on earth *else* would it do?" you clearly haven't seen some of
the more `interesting' C library implementations.

Note that these only work for ASCII. So if you're expecting `toupper'
to work for accented characters... dream on. :-)

All routines work on the char in A. The conversion routines (`to...')
return the modified char in A, too. The testing routines (`is...')
return nc if the test failed, else c. All registers not used for
returning results are preserved by all routines.

Having made that clear, there's no point doing the usual entry/exit
stuff for each routine - I'll simply list what they test/do.

```
isalpha - is char a letter?

isupper - is char an uppercase letter?

islower - is char a lowercase letter?

isdigit - is char a (decimal) digit?

isxdigit - is char a hex digit? (is that a hexit? :-))

isalnum - is char alphanumeric?

isspace - is char whitespace?
```
(For the purposes of `isspace', whitespace is defined as any of space,
FF, CR, LF, HT (tab) or even VT. This is the way it's defined in C, so
I did the same. If you're wondering (like I did) why VT was included,
check out the values of the chars on an ASCII chart...)
```
isprint - is char printable? (i.e. in range 32<=A<=126)

isgraph - is char printable and not space?

iscntrl - is char a control char? (i.e. in range A<32)

isascii - is char an ASCII char? (i.e. in range A<128)

toupper - convert char to uppercase

tolower - convert char to lowercase

toascii - strip top bit of char to make it 7-bit ASCII

ispunct - is char punctuation? (i.e. ASCII, but not space or alphanumeric)
```

##   getopt.z

A clone of Unix's getopt routine for parsing command-line options.
Requires args (and thus string and ctype). Note that *this is not
re-entrant*, so you may want to put a `ret' (C9h) at 0100h when
starting up, to prevent people using `!!' (or a zero-length .com file)
to re-run the program.

For the uninitiated, getopt parses Unix-style cmdline options, which
work like this:

- an option-setting argument starts with the `-' char. Then each char
  after that in the arg sets an option, unless the option takes an
  arg:

- options can take an arg, in which case the next arg is absorbed by
  that, and option processing continues on the next arg after. (The
  option's arg is put in the string at `optarg' on return from
  getopt.)

- the 1st arg which *doesn't* start with `-', and which isn't an
  option's arg, terminates option processing. (Traditionally, these
  remaining args tend to be filenames, but they can be whatever you
  want.) Most Unix getopts allow a `--' arg to terminate option
  processing too; this is not supported by this implementation (not
  yet, anyway).

This probably makes it sound like you call getopt once, and it sorts
everything out, right? Well, it doesn't quite work like that. You call
getopt once for each option on the cmdline, until they run out and
getopt returns "-1" (really 255 in this Z80 version). getopt also
signals bad options, etc., similarly: a `?' is returned when an
unknown option is found (the bad option letter is at `optopt'), and a
`:' is returned when an option's arg is missing.

When getopt returns 255, the index into argv of the first non-option
arg (if there is one) is in the byte at optind. If this equals argc,
there are no options left; if it's argc-1, there's one option left;
and so on.

When calling getopt, you pass an asciiz string describing the options.
For options which don't take args you just put the option letter in
the string; for options which do take args you put in the option
letter followed by `:'.

Here's a simple example which has `a' and `c' as simple options, and
`b' as an option which takes an arg. It just displays any options
given, ignores any arg to the `-b' option (!) and silently exits on
error. In addition to getopt, args, etc., it requires conio for
the putchar routine.

	org 0100h
	
	call makeargv
	
	optloop:
	ld hl,optstr
	call getopt
	
	cp 255
	ret z		;exit at end of options
	
	call putchar	;show option (or error) char
	
	cp ':'		;missing option arg
	ret z
	cp '?'		;unknown option
	ret z
	jr optloop
	
	;option string
	optstr:	defb 'ab:c',0

So, after all that, describing what getopt does is simple... :-)


getopt
entry: HL=addr of option string
exit:  A=option (or error, etc.), F/BC/DE/HL corrupt

Parse command-line options. A clone of Unix's getopt routine.


##   graph.z

Most of the graphics routines. These predate NC200 support in ZCN, and
will not produce any visible output on an NC200. Note that all the
line and shape-drawing routines use the routine set by a call to
`pixstyle' to draw the pixels.

```
pixstyle
entry: HL=addr of pixel draw routine to use
exit:  none

Set the routine which all graphics routines use to draw a pixel (which
defaults to `pset'). The routines defined in graph.z which may be used
for this purpose are pset, preset, pxor, and versions of those
routines which don't check to see if the pixel to draw is onscreen
(which are therefore faster and more dangerous) called fastpset,
fastpres and fastpxor.

The pixel drawing routine must have these entry/exit conditions:
entry: DE=x pos, C=y pos
exit:  AF/BC/DE/HL corrupt


pos2addr
entry: DE=x pos, C=y pos
exit:  HL=addr on screen, C=mask with pixel set at pixel position,
	AF/B/DE corrupt

Convert pixel position to address/mask. This routine is primarily
intended for internal use, but feel free to use it directly.


pset, preset, pxor, fastpset, fastpres, fastpxor
entry: DE=x pos, C=y pos
exit:  AF/BC/DE/HL corrupt

Set/reset/xor the pixel at (de,c). 


pfillpat
entry: DE=x pos, C=y pos
exit:  AF/BC/DE/HL corrupt

Set/reset the pixel at (de,c) according to current fill pattern (as
selected with `setfill').


setfill
entry: HL=addr of fill bitmap
exit:  none

Set current fill pattern used by `pfillpat' to the 8x8 bitmap at hl.
The format of the bitmap is 8 bytes, one for each line, with the top
line first and bit 7 leftmost. Predefined bitmaps you can use are
`patblack', `patdgrey', `patmgrey', `patlgrey', and `patwhite', which
are respectively black, dark grey, grey, light grey, and white.
`patblack' is the default pattern.


hline
entry: (DE,C) and (HL,C) = endpoints of line
exit:  AF/BC/DE/HL corrupt

Draw horizontal line from (de,c) to (hl,c). Faster than the more
general `drawline'.


vline
entry: (DE,C) and (DE,B) = endpoints of line
exit:  AF/BC/DE/HL corrupt

Draw vertical line from (de,c) to (de,b). Faster than the more general
`drawline'.


drawline
entry: (DE,C) and (HL,B) = endpoints of line
exit:  AF/BC/DE/HL corrupt

Draw a line from (de,c) to (hl,b).


rect
entry: (DE,C) and (HL,B) are co-ords of opposing corners
exit:  AF/BC/DE/HL corrupt

Draw a rectangle (outline) from (de,c) to (hl,b). Usually (de,c) will
be the top-left corner and (hl,b) the bottom-right, but they can
actually be any two diagonally-opposing corners.


frect
entry: (DE,C) and (HL,B) are co-ords of opposing corners
exit:  AF/BC/DE/HL corrupt

As `rect', but draw a filled rectangle.


clrscrn
entry: none
exit:  F/B/DE/HL corrupt

A fast clear screen routine. It's three times faster than the
`obvious' implementation using LDIR.

However, and I know this sounds bizarre, there is a chance of it
corrupting data in a small part (about 0.5%) of the serial input
buffer. Usually this won't be a problem, but I mention it here just in
case it is. You can avoid this problem completely by calling the
routine with interrupts disabled.


pget
entry: (DE,C) = pixel to get
exit:  A=FFh if `on' (black), 0 if `off' (white);
	F/BC/DE/HL corrupt

Get the current state of a pixel on the screen, and return it in A.


flood
entry: (DE,C) = seed pixel to start filling from
exit:  AF/BC/DE/HL corrupt

Fills in black all pixels inside a continuous black boundary, moving
outwards from (de,c) which must be inside the shape to fill. (This
method is called a floodfill, which gives the routine its name.)

This routine needs a *large* amount of usable stack space. I think the
worst case requires 5k.


draw8x8
entry: (DE,C) = where to draw the bitmap, IX=addr of bitmap
exit:  AF/BC/DE/HL/IX corrupt

Draw an 8x8 bitmap at (de,c). This (and other bitmap-drawing routines
here) is really only intended to support the mouse pointer drawing
required by mouse.z, but feel free to use it/them for other purposes.
The 8x8 bitmap should be in the same format as that specified in the
description of the `setfill' routine.


save16x8
entry: (DE,C) = where to save from, IX=addr of buffer to copy to
exit:  AF/BC/DE/HL/IX corrupt

Copy 8x8 and surrounding area (hence 16x8) from (DE,C) to IX. You'd
usually do this before drawing a bitmap there if you wanted to be able
to restore the original background later, e.g. if you wanted a
`sprite'.


rstr16x8
entry: (DE,C) = where to restore to, IX=addr of buffer to copy from
exit:  AF/BC/DE/HL/IX corrupt

Restore a 16x8 bitmap saved by `save16x8'.


##   graph2.z

More complicated graphics routines. Requires graph, maths and sqrt.


circle
entry: (DE,C) = centre, B=radius
exit:  AF/BC/DE/HL corrupt

Draw a circle centre (de,c) radius b. The square-root method is used
and two pixels are drawn for each pixel line, so that the circles tend
to break up at the top and bottom. For a better circle, you could try
drawing a filled circle with `fcircle' and `undraw' a filled circle
slightly smaller.


fcircle
entry: (DE,C) = centre, B=radius
exit:  AF/BC/DE/HL corrupt

As `circle', but draw a filled circle. As you might imagine, *this*
circle doesn't break up. :-)


ftri
entry: (DE,C) (HL,B) (IX,A) = co-ords of vertices
exit:  AF/BC/DE/HL/IX/IY corrupt

Draw a filled triangle with vertices (de,c), (hl,b), and (ix,a). This
is a rather complicated operation, and this routine is appropriately
slow, I'm afraid.

The triangle is only an approximation, and gets inaccurate when large.
The inaccuracy isn't major - about 1 pixel out per 480 pixels across -
but it can look strange because of the way the triangle is drawn. The
routine can sometimes `miss out' a pixel row when pxor is being used
as the pixel draw routine and one of the triangle's edges is vertical.
(In fact, it draws it twice, so the edge disappears and is `missing'.)
```

##   int32.z

A collection of maths routines which work on 32-bit integers. They're
not necessarily terribly good or anything, I just hacked them up so I
could write an fixed-point integer Mandelbrot program. But they *do*
work. Many of the routines use undocumented instructions, which may
not work under (incomplete) Z80 emulators.

Mul32/div32 work for unsigned numbers only. Smul32/sdiv32 are wrappers
around mul32/div32 which work for signed numbers, but they're slower
than mul32/div32, so only use them if you really need signed ops.

Note also that flags are almost certainly not meaningful for
mul32/div32/smul32/sdiv32; carry should be right for add32/sub32, but
don't expect any other flags to be.

As with the similar routines in maths.z, the number I/O routines (such
as atoi32 and dispdec32) only deal with unsigned numbers. It shouldn't
be too hard to get them to work with signed ones - see utils/expr.z in
ZCN for example code.

32-bit args to the routines are passed in one or both of ix/hl and
de/bc. ix and de are the most significant words of these args.

Some of these routines corrupt a LOT of registers, including IY and
the alternates in some cases, so check those `foo/bar/baz corrupt'
listings carefully!

```
swap32
entry: IXHL and DEBC = numbers to swap
exit:  IXHL and DEBC swapped, other registers preserved

Swap two 32-bit numbers.


iszero32
entry: IXHL = number
exit:  z if true, else nz; A corrupt

Test if a 32-bit number is zero.


inc32
entry: IXHL = number
exit:  IXHL = number+1, AF corrupt

Increment a 32-bit number.


dec32
entry: IXHL = number
exit:  IXHL = number-1, AF corrupt

Decrement a 32-bit number.


add32
entry: IXHL = num1, DEBC = num2
exit:  carry is correct, other flags corrupt, other regs preserved

Add debc to ixhl.


sub32
entry: IXHL = num1, DEBC = num2
exit:  carry is correct, other flags corrupt, other regs preserved

Subtract debc from ixhl.


mul32
entry: IXHL = unsigned num1, DEBC = unsigned num2
exit:  IXHL = num1*num2, AF/BC/DE/IY/BC'/DE'/HL' corrupt

Multiply ixhl by debc. ixhl and debc must be unsigned.


div32
entry: IXHL = unsigned num1, DEBC = unsigned num2
exit:  IXHL = num1/num2, DEBC = num1 mod num2;
	AF/IY/BC'/DE'/HL' corrupt

Divide ixhl by debc, and put remainder in debc. ixhl and debc must be
unsigned.


smul32
entry: IXHL = num1, DEBC = num2
exit:  IXHL = num1*num2, AF/BC/DE/IY/BC'/DE'/HL' corrupt

Multiply (signed) ixhl by debc.


sdiv32
entry: IXHL = num1, DEBC = num2
exit:  IXHL = num1/num2, DEBC = num1 mod num2;
	AF/IY/BC'/DE'/HL' corrupt

Divide (signed) ixhl by debc, and put remainder in debc.


abs32
entry: IXHL = num1
exit:  IXHL = abs(num1), AF/BC/DE corrupt

If num1 is negative, make it positive.


neg32
entry: IXHL = num1
exit:  IXHL = -num1, AF/BC/DE corrupt

Negate num1.


sgn32
entry: IXHL = num1
exit:  nc if num1>=0, else c; A corrupt
IXHL = num1*num2, AF/BC/DE/IY/BC'/DE'/HL' corrupt

Return nc if num1 is positive or zero, else c.


itoa32
entry: IXHL=number to convert
exit:  DE=addr of ASCII number in internal buffer, `$' terminated;
	AF/BC/HL/IX/IY/BC'/DE'/HL' corrupt

Convert 32-bit number in ixhl to ASCII.


itoabase32
entry: IXHL=number to convert, B=base to use
exit:  DE=addr of ASCII number in internal buffer, `$' terminated;
	AF/BC/HL/IX/IY/BC'/DE'/HL' corrupt

As `itoa32', but supports any base in range 2 to 36 rather than just
decimal.


dispdec32
entry: IXHL=number to print
exit:  AF/BC/DE/HL/IX/IY/BC'/DE'/HL' corrupt

Output 32-bit number in ixhl as decimal.


atoi32
entry: HL=addr of decimal ASCII number
exit:  IXHL=actual number, AF/BC/DE/IY/BC'/DE'/HL' corrupt

Convert number in ASCII to a 32-bit integer, and return that in ixhl.
The number should be terminated by any non-digit.


atoibase32
entry: HL=addr of ASCII number, B=base
exit:  IXHL=actual number, AF/BC/DE/IY/BC'/DE'/HL' corrupt

Convert number in ASCII in given base to a 32-bit integer, and return
that in ixhl. The number should be terminated by any char which is not
a digit in the given base.
```

##   maths.z

Integer maths routines such as fast multiply/divide, and number I/O
and conversion routines. Note that atoi/itoa (and routines which use
them) deal with *unsigned* numbers only.

```
disphex
entry: HL=number to print
exit:  AF corrupt

Output the number in hl as a 4-digit hex number.


hexbyte
entry: A=number to print
exit:  AF corrupt

Output the number in a as a 2-digit hex number.


multiply
entry: HL=num1, DE=num2
exit:  HL=num1*num2, AF/BC/DE corrupt

Multiply hl by de and return in hl.


divide
entry: HL=num1, DE=num2
exit:  HL=num1/num2, DE=num1 mod num2, AF/BC corrupt

Divide num1 by num2 and return result in hl and remainder in de.


itoa
entry: DE=number to convert
exit:  DE=addr of ASCII number in internal buffer, `$' terminated;
	AF/BC/HL corrupt

Convert number in de to ASCII.


itoabase
entry: DE=number to convert, B=base to use
exit:  DE=addr of ASCII number in internal buffer, `$' terminated;
	AF/BC/HL corrupt

As `itoa', but supports any base in range 2 to 36 rather than just
decimal.


dispdec
entry: DE=number to print
exit:  AF/BC/DE/HL corrupt

Output number in de as decimal.


atoi
entry: HL=addr of decimal ASCII number
exit:  HL=actual number, AF/BC/DE corrupt

Convert number in ASCII to an integer, and return that in hl. The
number should be terminated by any non-digit.


atoibase
entry: HL=addr of ASCII number, B=base
exit:  HL=actual number, AF/BC/DE corrupt

Convert number in ASCII in given base to an integer, and return that
in hl. The number should be terminated by any char which is not a
digit in the given base.
```

##   mouse.z

A driver for microsoft-mouse-compatible serial mice. Requires graph.
See `mousedem.z' for an example of how to use this.

NB: You should not attempt to use this driver on the NC200. You should
either exit on NC200, or remove the test for nc100em.

```
minit
entry: none
exit:  AF/BC/DE/HL corrupt

Initialise mouse. There's currently no way of being sure if there's
actually a mouse plugged in or not... :-(

You must call this routine before using any other mouse routines.

Before calling this routine, you may want to set (mfixp) to something
other than 0 for a slower-moving mouse. An explanation: There are
2^(mfixp) sub-pixel positions, so the bigger (mfixp) gets, the less
sensitive (slower) the mouse movement gets. It must be >=0 and <=7. 0
or 1 are generally ok, and 4 is good for high detail stuff.


muninit
entry: none
exit:  AF/BC/DE/HL corrupt

Uninitialise mouse. You must call this before exiting if you called
`minit'.


mouseon
entry: none
exit:  AF/BC/DE/HL/IX corrupt

Turn on mouse pointer. The pointer is redrawn each time you call
`mstat'. Call `mouseoff' to disable the pointer before drawing
anything onscreen yourself (and, of course, `mouseon' afterwards).


mouseoff
entry: none
exit:  AF/BC/DE/HL/IX corrupt

Turn off mouse pointer.


mevents
entry: none
exit:  AF/BC/DE/HL corrupt

Handle any mouse events pending. Call this reasonably often, certainly
before calling `mstat'.


mstat
entry: none
exit:  (DE,C) = mouse pointer co-ords, A=mouse buttons (bit 1 set if
	left pressed, bit 0 set if right); F/B/HL/IX corrupt

Get mouse status. Call `mevents' before calling this.
```

##   qsort.z

A simple generic sort routine like C's qsort. Requires maths.

WARNING! WARNING! There's a warning going on. It's still going on.
It's still a warning. This is a warning announcement. (Thanks Hol.)
There must be enough room at the end of the array for an extra
element, which is used when swapping elements in the array. This
sucks, but I couldn't think of a better solution. (Well, I did think
of one, but it'd have been much slower.)

Another warning - sorting zero-length arrays is a Bad Thing. Results
are undefined... because I don't want to frighten you. :-)

By the way, the sort routine isn't really a quicksort, it's just an
exchange sort. It's not all that much better than bubble sort for some
cases, but it's certainly the easiest and most intuitive sort to write
and understand. And since this is assembly, that's a good thing in my
book. Fewer bugs. :-)

Technical details for the interested who don't know how an exchange
sort is better than a bubble sort - while the number of comparisons is
the same, it almost always massively reduces the number of exchange
ops. So `exchange sort' is a silly name for it really. :-) As for how
the sort works, it's like this:

	for n=0 to nmemb-1
	  find smallest element (from elements n..nmemb-1)
	  exchange that with the nth element
	next

(It should really be `for n=0 to nmemb-2', but that causes problems
with 1-element arrays, of course!)

If you have, say, a 100-element array with the smallest element at the
end, exchange sort will do 98 fewer exchanges than bubble sort to get
it to the right place! With each exchange involving three block
copies, this is a major saving. And for the kind of relatively small
arrays you'll be sorting in the restricted Z80 address space, exchange
sort even compares reasonably well with the (old) famous `fast'
sorting algorithms, quicksort and shell-sort (which only get much
faster than other sorting methods when you have a large array to
sort).

But enough of this rubbish, and on with the description:

```
qsort
entry: HL=array base, BC=no. entries in array, DE=size of an element,
	IX=addr of element compare routine
exit:  AF/BC/DE/HL corrupt

Sorts an array. You must provide a routine to compare elements, which
should conform to this description:

entry: DE=element1, HL=element2
exit:  c  if element1 > element2;
       nc if element1 < element2;
       carry state doesn't matter if they're equal, return whatever's
	most convenient;
       AF/BC/DE/HL corrupt, if you like, but no others
```

##   rand.z

A relatively simple and fast pseudo-random number generator. Requires
routines from maths. The random number generator used is based on the
(public domain) C++ original in Chris Doty-Humphrey's PractRand.

For an alternative (but slower) RNG, see `zcsoli', but note the
licence. It's also worth noting that the faster RNG in rand.z does
seem to give statistically better results.

```
srand
entry: none
exit:  AF/HL corrupt

Set (or rather, modify) random number seed using the refresh register
R (seven bits of which will usually be relatively random). On ZCN,
`srand' will also use the RTC time. Either way, the RNG is then given
a few runs to perturb the initial state.

You should always call this routine, to initialise the RNG, before
making any calls to `rand' and/or `rand16'. It can take a while to
run, at least relative to those other routines, and it's best to only
call it once.

If you have a better source for a seed, be sure to use it (by
modifying the six bytes at `seed' *before* calling srand) - especially
if you're relying on just the R register, as it effectively means
there are only 128 possible random number sequences!

(Well, there are strictly speaking 256 sequences, but as the Z80 only
increments the low 7 bits of R, it's effectively only 128.)


rand
entry: HL=range size
exit:  HL=random number in range 0 to range_size-1 inclusive;
	AF/BC/DE corrupt

Return a random number in the given range in hl. This is exactly
equivalent to `rand()%range_size' in C.


rand16
entry: none
exit:  HL=random number, AF/BC/DE corrupt

Return a 16-bit random number (i.e. in the range 0 to 65535
inclusive). This is faster than `rand'.
```

##   sqrt.z

An integer square-root routine.

```
intsqrt
entry: HL=number
exit:  HL=sqrt (only L significant), AF/BC/DE/IX corrupt

Return integer square-root of number. Only the integer part of the
sqrt is given, so for example sqrt(99) is given as 9.
```

##   stdio.z

File I/O routines based on a subset of C's "stdio"; rather easier to
use than CP/M's 128-byte records and FCBs. On the other hand, they're
(necessarily) slower than the native I/O, so there's no free lunch.
You'll have to make up your own mind which I/O interface you prefer.

As for my opinion... For bulk I/O, like copying a file, CP/M's I/O is
faster and almost as easy. This probably applies to most binary I/O,
actually. But for text files, CP/M is a total pain, and these routines
are *much* better.

```
fopen
entry: HL=address of asciiz filename
        (however, it can actually end in a space if you want),
       A=0 to read text, 1 to write text, 2 to read binary, or 3 to
        write binary.
exit:  nc if couldn't open, else c if ok;
       if ok, HL=file handle;
       always, AF/BC/DE/IX corrupt

Open a file. A indicates the file mode. Binary files are read/written
without any conversion, while in text files CRs are stripped when
reading and added (before LFs) when writing. This gives a C-like feel
to file ops. Also, a ^Z character is treated as ending a text file (as
required in CP/M), and a ^Z is written when a text file is closed.


fopenr/fopenw/fopenrb/fopenwb
entry: HL=address of asciiz filename
        (however, it can actually end in a space if you want),
exit:  nc if couldn't open, else c if ok;
       if ok, HL=file handle;
       always, AF/BC/DE/IX corrupt

These routines set A to the relevant value and call fopen. It's
usually more mnemonic to call these than using fopen directly and
actually bothering to set A yourself.


fopenfcb
entry: HL=addr of FCB, A=file mode (as for fopen)
exit:  nc if couldn't open, else c if ok;
       if ok, HL=file handle;
       always, AF/BC/DE/IX corrupt

Open file specified in the FCB. This can sometimes be easier to use
than `fopen', such as when opening a file using the FCBs provided by
CP/M at 005Ch and 006Ch.

The FCB pointed to by HL is not used or modified (simply copied), and
only the first 12 bytes are relevant.


makefn83
entry: HL=address of asciiz filename, DE=address of FCB
exit:  AF/BC/DE/HL corrupt

Convert an asciiz filename at hl to FCB format name at de.


fclose
entry: HL=file handle
exit:  nc if file write error when closing, else c;
	AF/BC/DE/HL/IX corrupt

Close the file. Call this for *ALL* files you opened with fopen etc.,
not just ones you wrote to - if you don't close a file, the file
handle remains allocated. (And there are only 3, so this can be a
problem!)


fread
entry: HL=file handle, DE=address to read bytes at, BC=no. bytes
exit:  BC=no. bytes actually read, AF/DE/HL/IX corrupt

Read (up to) a certain number of bytes from a file. (Note that the
carry status is not used to signal an error here!) This is implemented
in terms of fgetc, and is simply a convenience routine - do not expect
it to be any faster than multiple calls to fgetc.


fwrite
entry: HL=file handle, DE=address to write bytes from, BC=no. bytes
exit:  BC=no. bytes actually written, AF/DE/HL/IX corrupt

Write (up to) a certain number of bytes to a file. (Note that the
carry status is not used to signal an error here!) This is implemented
in terms of fputc, and is simply a convenience routine - do not expect
it to be any faster than multiple calls to fputc.


fgetc
entry: HL=file handle
exit:  if c, ok and A=char from file - if nc, error reading or EOF;
	F/BC/DE/HL/IX corrupt

Get a char from file into A. If reading in text mode, CRs are dropped.


fputc
entry: HL=file handle, A=char to write
exit:  c if ok, else nc if write error (usually means disk is full);
	F/BC/DE/HL/IX corrupt

Write the char in A to the file. If writing in text mode, CRs are
added before any LFs written.


fseek
entry: HL=file handle, CDE=offset in file to seek to, in bytes (C is MSB)
exit:  AF/BC/DE/HL/IX corrupt

Seek to a new position in the file. Note that for the purposes of
fseek/ftell *only*, text files are treated exactly the same as binary
files are.


ftell
entry: HL=file handle
exit:  CDE=current offset in file, in bytes (C is MSB);
	AF/B/HL/IX corrupt

Return current position in file. Note that for the purposes of
fseek/ftell *only*, text files are treated exactly the same as binary
files are.


fgets
entry: HL=file handle, DE=addr to read line in at, BC=max bytes to read
exit:  AF/BC/DE/HL/IX corrupt

Get a line from the file, up to the max. length given in bc. Carry is
not used to signal an error - a zero-length returned string indicates
error reading or EOF.

The string will contain an LF if it was shorter than the max. length;
you can remove this with strchop from `string.z' if need be.


fputs
entry: HL=file handle, DE=addr of line to write
exit:  c if ok, else nc if error writing; AF/BC/DE/HL/IX corrupt

Write a line to the file. This writes exactly the string at de
(subject to any text-mode conversions), and doesn't add any LF.
```

##   string.z

Routines for manipulating C-like asciiz strings. Mostly based on
equivalent C library routines.

```
strlen
entry: HL=addr of string
exit:  BC=length of string, excluding trailing NUL;
       HL=addr of trailing NUL;
       AF corrupt

Return length of string (and address of trailing NUL).


strstr
entry: HL=`needle' string, DE=`haystack' string
exit:  HL=addr of first occurance of `needle', or 0 if none

Find `needle' in `haystack', and return address in hl.


strcmp
entry: HL=string1, DE=string2
exit:  c if they match, else nc; AF/DE/HL corrupt

Compare strings at hl and de. Unlike the C function, this only tests
for equality.


strncmp
entry: HL=string1, DE=string2, BC=no. bytes to compare
exit:  c if they match, else nc; AF/BC/DE/HL corrupt

Compare bc bytes of strings at hl and de. Tests for equality only.


strcpy
entry: HL=destination, DE=source
exit:  HL and DE both point to the NUL in each copy; AF corrupt

Copy string from de to hl.


strcat
entry: HL=destination, DE=source
exit:  HL and DE both point to the NUL in each copy; AF/BC corrupt

Add string from de onto the end of string at hl.


strncpy
entry: HL=destination, DE=source, BC=no. bytes to copy
exit:  F/BC/DE/HL corrupt

Copy bc bytes from de to hl. Does not add any NUL.


strchr
entry: HL=string, E=char to search for
exit:  HL=address of first occurrence of char in string, or 0 if none;
	AF corrupt

Find leftmost occurrence of char in string.


strrchr
entry: HL=string, E=char to search for
exit:  HL=address of last occurrence of char in string, or 0 if none;
	AF corrupt

Find rightmost occurrence of char in string.


strprint
entry: HL=addr of string
exit:  AF/HL corrupt

Print string at hl. Does not add any CR/LF.


ilprint
entry: none (see description)
exit:  AF/DE/HL corrupt

Print a string inlined in the code of the caller. To use, do something
like:

	call ilprint
	defb 'Hello world',0

The return address is altered such that execution continues after the
inlined string.


strchop
entry: HL=string
exit:  AF/BC/HL corrupt

Remove any trailing LF from the string. This is like the Perl `chop'
command. This can be useful for strings read with stdio's fgets
routine.
```

# Contacting the author

You can email me at zgedneil@gmail.com.