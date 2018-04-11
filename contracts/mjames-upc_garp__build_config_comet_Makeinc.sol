###################################################################
###################################################################
#
#       Makefile for Nawips 5.2.1
#               Top level
#               COMET 7/95 D.Himes
#               Original: Unidata 7/94 P.Bruehl
#
####################################################################
####################################################################
####################################################################
#
# NOTE:  This file is included by the
#             $(NAWIPS)/config/Makeinc.common
#
#################################################################
#
# This file is included by the $(NAWIPS)/config/Makeinc.common
# file (which is directly included by all the Nprogram makefiles
# and indirectly by the Gempak makefiles.
#
# It defines the paths and filenames needed to compile and install
# Nawips.
#
# Please configure the settings below to match the configuration
# of your system.
#
#################################################################
#
##-------------------------------------------------------------
#
## Sun Solaris (SunOS 5.X)
## You must have MOTIF to build this software
##
PLATFORM = SOLARIS
OPSYS    = SOLARIS
OS       = SunOS


#
##  Fortran and C compiler
#
CC = cc 
FC = f77

#
##  Misc. utilities
#       Add -s option to install to have the executables stripped.
INSTALL = /usr/ucb/install
RANLIB = :

#
## C Options include: -O optimization; -p profiling; -g debugging
#
##### NOTE took out -DSYSV!!!!
COPT = -DUNDERSCORE -D$(OS) -g
FOPT = -g



#
## System libraries needed
#
#SYSLIBS = -lsocket  -lgen
SYSLIBS = -lm

#
## Location of MOTIF library and include files (Solaris 2.4)
#
MOTIFLIBS = -L/usr/dt/lib -lXm
MOTIFINC = -I/usr/dt/include

#
## Location of X11 library and include files  (Solaris 2.4)
#
#X11LIBS    = -L/usr/openwin/lib -lXt -lX11
X11LIBS    = -L/usr/openwin/lib -lXmu -lXt -lXext -lXaw -lX11
XWLIBDIR   = -L/usr/openwin/lib

X11INC     = -I/usr/openwin/include
XWINCDIR   = $(X11INC)

## Compiling options for the ldmbridge decoder
#
BRIDGE_DEF = -DGEMPAK -DSTDC

#
##  Other possible places for X and Motif
#
#X11LIBS = -L/opt/SUNWmotif/lib -lXm -L/usr/openwin/lib -lXt -lX11 \
#		-R/opt/SUNWmotif/lib -R/usr/openwin/lib 
#XWINCDIR = -I/opt/SUNWmotif/include -I/usr/openwin/include

#
# MIT's X11R5
#
#X11LIBS= -L/usr/local/X11R5/lib -lXm -lXt -lX11 -R/usr/local/X11R5/lib
#XWINCDIR = -I/usr/local/X11R5/include

# Special libraries for making statically linked binaries
# Leave these commented out
# Sun Solaris - Openwindows & Sun Motif
#STATICSYSLIBS = -lF77 -lsocket -lgen -lnsl -lintl -lw 
# Sun OS4.x
#STATICSYSLIBS = 

#
######################################################################
#
#   Xpm: If your system has Xpm, point XPMINCLUDE and XPMLIB to your
#   local copies and set the XPMSOURCE macro to nothing. If instead you
#   will be building the GARP-supplied copy of xpm, comment out the xpm
#   macros except for XPMDEFINES which you should set accordingly.
#
#XPMINCLUDE  = -I/usr/local/XDesigner/xpm
#XPMLIB      = -L/usr/local/XDesigner/xpm -lXpm
#XPMSOURCE   =
#
#  if your system doesn't provide strcasecmp add -DNEED_STRCASECMP
#  if your system doesn't provide pipe remove -DZPIPE
#
XPMDEFINES  = -DZPIPE
#
######################################################################

##-------------------------------------------------------------
##
##  Define compile,link,archive, & remove variables 
##  (leave as is)
##
#
CFLAGS    = $(COPT)
FFLAGS    = $(FOPT)
COMPILE.f = $(FC) $(FFLAGS)  -c
LINK.f    = $(FC) $(FFLAGS) $(LDFLAGS)
COMPILE.c = $(CC) $(CFLAGS)  -c
LINK.c	  = $(CC) $(LDFLAGS)
