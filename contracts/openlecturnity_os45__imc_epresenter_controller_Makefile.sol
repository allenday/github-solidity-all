#
#  Makefile 1.34 92/03/03 08:38:35
#

SHELL = /bin/sh

PATH     = ./

DEFINES = -DLINUX 
INCLUDES = -I/usr/include
FLAGS = 
LIBRARIES = -lsocket 

OBJECTS = $(PATH)eppControl.o

CC = /usr/local/gnu/bin/g++ -w -g -DLINUX $(INCLUDES)

default : $(OBJECTS) 
	/bin/rm -f $(PATH)eppC
	$(CC)  -o $(PATH)eppC $(FLAGS) $(OBJECTS) $(LIBRARIES)
	/bin/mv eppC bin/eppC_sol

clean :
	/bin/rm -f *.o *~ core 

$(PATH)eppControl.o : $(PATH)eppControl.cpp
	$(CC) -o $@ -c  $(SP)eppControl.cpp
