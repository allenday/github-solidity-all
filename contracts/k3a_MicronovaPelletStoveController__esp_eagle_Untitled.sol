%!PS-Adobe-3.0 EPSF-3.0
%%Title: EAGLE Drawing /Users/kexik/Documents/eagle/ESP_Stufa/Untitled.brd
%%Creator: EAGLE
%%Pages: 1
%%BoundingBox: 0 0 187 91
%%EndComments

% Coordinate transfer:

/EU { 254 div 0.072 mul } def
/inch { 72 mul } def

% Linestyle:

1 setlinecap
1 setlinejoin

% Drawing functions:

/l {  % draw a line
   /lw exch def
   /y2 exch def
   /x2 exch def
   /y1 exch def
   /x1 exch def
   newpath
   x1 EU y1 EU moveto
   x2 EU y2 EU lineto
   lw EU setlinewidth
   stroke
   } def

/h {  % draw a hole
   /d  exch def
   /y  exch def
   /x  exch def
   d 0 gt {
     newpath
     x EU y EU d 2 div EU 0 360 arc
     currentgray dup
     1 exch sub setgray
     fill
     setgray
     } if
   } def

/b {  % draw a bar
   /an exch def
   /y2 exch def
   /x2 exch def
   /y1 exch def
   /x1 exch def
   /w2 x2 x1 sub 2 div EU def
   /h2 y2 y1 sub 2 div EU def
   gsave
   x1 x2 add 2 div EU y1 y2 add 2 div EU translate
   an rotate
   newpath
   w2     h2     moveto
   w2 neg h2     lineto
   w2 neg h2 neg lineto
   w2     h2 neg lineto
   closepath
   fill
   grestore
   } def

/c {  % draw a circle
   /lw exch def
   /rd exch def
   /y  exch def
   /x  exch def
   newpath
   lw EU setlinewidth
   x EU y EU rd EU 0 360 arc
   stroke
   } def

/a {  % draw an arc
   /lc exch def
   /ae exch def
   /as exch def
   /lw exch def
   /rd exch def
   /y  exch def
   /x  exch def
   lw rd 2 mul gt {
     /rd rd lw 2 div add 2 div def
     /lw rd 2 mul def
     } if
   currentlinecap currentlinejoin
   lc setlinecap 0 setlinejoin
   newpath
   lw EU setlinewidth
   x EU y EU rd EU as ae arc
   stroke
   setlinejoin setlinecap
   } def

/p {  % draw a pie
   /d exch def
   /y exch def
   /x exch def
   newpath
   x EU y EU d 2 div EU 0 360 arc
   fill
   } def

/edge { 0.20710678119 mul } def

/o {  % draw an octagon
   /an exch def
   /dy exch def
   /dx exch def
   /y  exch def
   /x  exch def
   gsave
   x EU y EU translate
   an dx dy lt { 90 add /dx dy /dy dx def def } if rotate
   newpath
      0 dx 2 div sub EU                    0 dy edge  add EU moveto
      0 dx dy sub 2 div sub dy edge sub EU 0 dy 2 div add EU lineto
      0 dx dy sub 2 div add dy edge add EU 0 dy 2 div add EU lineto
      0 dx 2 div add EU                    0 dy edge  add EU lineto
      0 dx 2 div add EU                    0 dy edge  sub EU lineto
      0 dx dy sub 2 div add dy edge add EU 0 dy 2 div sub EU lineto
      0 dx dy sub 2 div sub dy edge sub EU 0 dy 2 div sub EU lineto
      0 dx 2 div sub EU                    0 dy edge  sub EU lineto
   closepath
   fill
   grestore
   } def

0 0 580000 0 0 l
580000 0 580000 310000 0 l
580000 310000 0 310000 0 l
0 310000 0 0 0 l
97962 90412 116758 109208 90.0 b
107360 127510 18796 p
107360 155210 18796 p
107360 182910 18796 p
107360 210610 18796 p
78960 113710 18796 p
78960 141410 18796 p
78960 169010 18796 p
78960 196710 18796 p
93160 30210 50800 p
93160 280210 50800 p
340388 37888 354612 52112 0.0 b
347500 45000 347500 95000 5000 l
340388 87888 354612 102112 0.0 b
320388 87888 334612 102112 0.0 b
327500 95000 327500 45000 5000 l
320388 37888 334612 52112 0.0 b
107360 99810 10160 h
107360 127510 10160 h
107360 155210 10160 h
107360 182910 10160 h
107360 210610 10160 h
78960 113710 10160 h
78960 141410 10160 h
78960 169010 10160 h
78960 196710 10160 h
93160 30210 33020 h
93160 280210 33020 h
347500 45000 6000 h
347500 95000 6000 h
327500 95000 6000 h
327500 45000 6000 h
