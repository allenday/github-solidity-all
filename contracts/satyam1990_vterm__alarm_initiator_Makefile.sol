CXX = /vobs/ossrc_3pp/freeware/studio11/SUNWspro/bin/CC 

INCLUDES = -I../utils

LIBS = -lsocket -lnsl

OBJS =  AlarmInitiator.o main.o

HELPER_OBJ = ../utils/*.o

alarmInitiator: $(OBJS)
	$(CXX) -o $@ $(OBJS) $(HELPER_OBJ) $(INCLUDES) $(LIBS)

AlarmInitiator.o: AlarmInitiator.cc AlarmInitiator.hh ../utils/Helper.hh
	$(CXX) -o $@ -c $<  $(INCLUDES) $(LIBS)

main.o: main.cc AlarmInitiator.hh ../utils/Helper.hh
	$(CXX) -o $@ -c $<  $(INCLUDES) $(LIBS)

.PHONY: clean
clean:
	rm -rf *.o alarmInitiator
