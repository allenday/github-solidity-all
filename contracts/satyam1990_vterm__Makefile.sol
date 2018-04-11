CXX = /vobs/ossrc_3pp/freeware/studio11/SUNWspro/bin/CC

LIBDIR = -L/vobs/ossrc_3pp/cif_3pp/borland_enterprise_server/lib

DEBUG_FLAGS = -ggdb

LIBS = -lxerces-c_2_7

BINDIR = bin

DIRS = cmd_handler utils mo_parser ui alarm_initiator

INCLUDES = -I/vobs/ossrc_3pp/cif_3pp/borland_enterprise_server/include \
			-Icmd_handler \
			-Iutils \
			-Imo_parser

OBJS = cmd_handler/*.o utils/*.o mo_parser/*.o

vterm: subdirs
	$(CXX) -o $@ main.cc $(OBJS) $(INCLUDES) $(LIBDIR) $(LIBS)
	@echo "\nCompilation Successful!"

install:
	rm -rf wans
	mkdir wans
	mkdir wans/bin
	mkdir wans/etc
	mkdir wans/mml_command_output
	cp -r vterm deps/emt_tgw_telnetd ui/main etc/scripts/* wans/bin
	cp ui/scripts/* wans/bin
	cp alarm_initiator/alarmInitiator wans/bin
	cp etc/mo.xml wans/etc
	cp etc/wans_5000-tcp.xml.template wans/etc
	mv wans/bin/launch_gui.sh wans
	tar -cvf wans.tar wans
	rm -rf wans
	@echo "\nWANS Tarball Successfully prepared!"

subdirs:
	@for dir in $(DIRS); do \
		cd $$dir; $(MAKE) -f Makefile.sol; cd ..; \
		if [ $$? -ne 0 ]; then \
			exit 1; \
		fi; \
	done

clean:
	@for dir in $(DIRS); do \
		cd $$dir; $(MAKE) -f Makefile.sol clean; cd ..; \
	done
	rm -rf vterm wans.tar
