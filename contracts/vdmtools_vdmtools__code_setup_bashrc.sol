#
#
#

umask 022

export EDITOR=vi

# for sfw, ccs
export PATH=/usr/sfw/bin:/usr/ccs/bin:${PATH}
export LD_LIBRARY_PATH=/usr/sfw/lib:/usr/ccs/lib:${LD_LIBRARY_PATH}

# for java, ant
export JDKHOME=/usr/java
export ANTHOME=/usr/local/apache-ant-1.7.1
export PATH=${ANTHOME}/bin:${PATH}

export JAVACCHOME=/usr/local/javacc-5.0

export PYTHON=/usr/bin/python2.4

# for local
export PATH=/usr/local/bin:${PATH}
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

# for Qt
export QTDIR=/usr/local/qt
export PATH=${QTDIR}/bin:${PATH}
export LD_LIBRARY_PATH=${QTDIR}/lib:${LD_LIBRARY_PATH}

# for omniORB
export CORBADIR=/usr/local/omniORB
export PATH=${CORBADIR}/bin:${PATH}
export LD_LIBRARY_PATH=${CORBADIR}/lib:${LD_LIBRARY_PATH}

# for building VDM
export YACC=bison-2.3
export OSTYPE=`uname`
export PATH=${PATH}:${HOME}/bin:.

# for powertest
export TBDIR=${HOME}/vdmtools
export POWERTEST=${TBDIR}/test/powertest/powertest
export POWERTESTDIR=${HOME}/powertest
export TESTDIR=${POWERTESTDIR}

