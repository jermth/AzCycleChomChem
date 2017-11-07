#! /bin/bash -x

mkdir -p /shared/modulefiles

cat > /etc/profile.d/env_modules.sh << 'FILE'
#! /bin/sh
export MODULEPATH=/shared/modulefiles:$MODULEPATH
FILE


cat > /etc/profile.d/env_modules.csh << 'FILE'
#! /bin/csh
setenv MODULEPATH /shared/modulefiles:$MODULEPATH
FILE

