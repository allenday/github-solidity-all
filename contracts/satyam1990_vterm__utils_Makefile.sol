CXX = /vobs/ossrc_3pp/freeware/studio11/SUNWspro/bin/CC

OBJS = Helper.o

all: $(OBJS)

Helper.o: Helper.cc Helper.hh
	$(CXX) -o $@ -c $<

.PHONY: clean
clean:
	rm -rf *.o
