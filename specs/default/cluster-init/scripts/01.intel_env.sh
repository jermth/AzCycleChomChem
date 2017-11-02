#! /bin/bash -e

# add intel compilers and mpi into user envs


cat > /etc/profile.d/intel.sh << 'FILE'
#! /bin/sh
if [ -d /opt/intel ];then
. /opt/intel/compilers_and_libraries/linux/mpi/intel64/bin/mpivars.sh
source /opt/intel/compilers_and_libraries_2017.2.174/linux/bin/compilervars.sh intel64
fi
FILE

cat > /etc/profile.d/intel.csh << 'FILE'
#! /bin/csh
if (-d /opt/intel) then    
. /opt/intel/compilers_and_libraries/linux/mpi/intel64/bin/mpivars.csh
source /opt/intel/compilers_and_libraries_2017.2.174/linux/bin/compilervars.csh intel64
endif
FILE
