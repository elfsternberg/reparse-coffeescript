# ReParse - Coffeescript Edition

## Purpose

This is a hand-written re-implementation of Ben Weaver's ReParse
(https://github.com/weaver/ReParse).  It is a (mostly) faithful
reimplementation, although a few things were re-arranged to be more in
line with Haskell's parsec library, with a side-line look at JSParsec.
This version uses the Coffeescript class management toolkit, so it
*looks* much more like a classic duck-typed OO implementation, the
kind of thing you're familiar with from Ruby or Python.  Take a peek
at the examples and you'll see what I mean-- I think they're 20%
cooler that Ben's, just 'cuz of how they look.

I made the parser re-usable with a new input; it's slightly faster
than the javascript implementation.

I wrote this because I needed a parser for a coffeescript project, and
while I liked Ben's code, I needed to disassemble it, figure out what
it did, and re-write it in my own language and with my own brain.
It's been nearly 14 years since I last had to write a parser; I
usually work at a much higher level, but my current project required
one, and this was the exercise I chose.

## Requirements

Coffeescript to build/run.

Docco to produce documentation. 

Both of these are specified in the package.json file.

## Acknowledgements

Ben Weaver (of course)

Balazs Endresz (for JSParsec, which at least explained some functions
of Parsec to me better than the Parsec source code)

John MacFarlane (for Pandoc, which led me down this rabbit hole in the
first place)

## LICENSE AND COPYRIGHT NOTICE: NO WARRANTY GRANTED OR IMPLIED

Copyright (c) 2012 Elf M. Sternberg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

	- Elf M. Sternberg <elf@pendorwright.com>




