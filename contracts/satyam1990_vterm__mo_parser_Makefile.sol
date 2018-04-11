CXX = /vobs/ossrc_3pp/freeware/studio11/SUNWspro/bin/CC

OBJS = Mo.o MoList.o MoTree.o

INCLUDES = -I/vobs/ossrc_3pp/cif_3pp/borland_enterprise_server/include \
			-I../utils

all: $(OBJS)

Mo.o: Mo.cc Mo.hh MoList.hh xercesc.hh ../utils/Helper.hh
	$(CXX) -o $@ -c $< $(INCLUDES)

MoList.o: MoList.cc MoList.hh Mo.hh ../utils/Helper.hh xercesc.hh
	$(CXX) -o $@ -c $< $(INCLUDES)

MoTree.o: MoTree.cc MoTree.hh MoList.hh Mo.hh ../utils/Helper.hh \
 					xercesc.hh
	$(CXX) -o $@ -c $< $(INCLUDES)

.PHONY: clean
clean:
	rm -rf *.o
