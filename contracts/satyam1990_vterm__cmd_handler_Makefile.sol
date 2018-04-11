CXX = /vobs/ossrc_3pp/freeware/studio11/SUNWspro/bin/CC

INCLUDES = -I/vobs/ossrc_3pp/cif_3pp/borland_enterprise_server/include \
			-I../mo_parser \
			-I../utils

OBJS =  Terminal.o MMLProcessor.o APLOCProcessor.o \
		Response.o MMLResponse.o APLOCResponse.o

all: $(OBJS) 

Terminal.o: Terminal.cc Terminal.hh MMLProcessor.hh MMLResponse.hh \
 						Response.hh ../utils/Helper.hh APLOCProcessor.hh \
						../mo_parser/MoTree.hh ../mo_parser/MoList.hh \
						../mo_parser/Mo.hh ../mo_parser/xercesc.hh \
 						../mo_parser/MoList.hh ../mo_parser/Mo.hh \
						APLOCResponse.hh
	$(CXX) -o $@ -c $<  $(INCLUDES)

MMLProcessor.o: MMLProcessor.cc MMLProcessor.hh MMLResponse.hh \
 							Response.hh ../utils/Helper.hh
	$(CXX) -o $@ -c $<  $(INCLUDES)

APLOCProcessor.o: APLOCProcessor.cc APLOCProcessor.hh \
 							../mo_parser/MoTree.hh ../mo_parser/MoList.hh \
							../mo_parser/Mo.hh ../utils/Helper.hh ../mo_parser/xercesc.hh \
							../mo_parser/MoList.hh \
 							../mo_parser/Mo.hh APLOCResponse.hh Response.hh
	$(CXX) -o $@ -c $<  $(INCLUDES)

Response.o: Response.cc Response.hh
	$(CXX) -o $@ -c $<  $(INCLUDES)

MMLResponse.o: MMLResponse.cc MMLResponse.hh Response.hh
	$(CXX) -o $@ -c $<  $(INCLUDES)

APLOCResponse.o: APLOCResponse.cc APLOCResponse.hh Response.hh
	$(CXX) -o $@ -c $<  $(INCLUDES)

.PHONY: clean
clean:
	rm -rf *.o
