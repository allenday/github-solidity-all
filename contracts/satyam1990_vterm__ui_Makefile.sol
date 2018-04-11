CXX = /vobs/ossrc_3pp/freeware/studio11/SUNWspro/bin/CC

OBJS = MainWindow.o EventHandler.o MoPathEditorDialog.o \
		MmlPathEditorDialog.o  DdEditorDialog.o main.o

HELPER_OBJ = ../utils/*.o

INCLUDES = -I../utils

LIBS = `pkg-config gtk+-2.0 --cflags --libs`

main: $(OBJS)
	$(CXX) -o $@ $(OBJS) $(HELPER_OBJ) $(INCLUDES) $(LIBS)

MainWindow.o: MainWindow.cc MainWindow.hh EventHandler.hh ../utils/Helper.hh
	$(CXX) -o $@ -c $< $(INCLUDES) $(LIBS)

EventHandler.o: EventHandler.cc EventHandler.hh MainWindow.hh MoPathEditorDialog.hh MmlPathEditorDialog.hh
	$(CXX) -o $@ -c $< $(INCLUDES) $(LIBS)

MoPathEditorDialog.o: MoPathEditorDialog.cc MoPathEditorDialog.hh ../utils/Helper.hh
	$(CXX) -o $@ -c $< $(INCLUDES) $(LIBS)

MmlPathEditorDialog.o: MmlPathEditorDialog.cc MmlPathEditorDialog.hh ../utils/Helper.hh
	$(CXX) -o $@ -c $< $(INCLUDES) $(LIBS)

DdEditorDialog.o: DdEditorDialog.cc DdEditorDialog.hh ../utils/Helper.hh
	$(CXX) -o $@ -c $< $(INCLUDES) $(LIBS)

main.o: main.cc MainWindow.hh EventHandler.hh ../utils/Helper.hh
	$(CXX) -o $@ -c $< $(INCLUDES) $(LIBS)

.PHONY: clean
clean:
	rm -rf *.o main
