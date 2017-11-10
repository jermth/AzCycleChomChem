#! /bin/bash -e

if [ test -f $CYCLECLOUD_SPEC_PATH/files/espresso-5.4.0.centos71.intel.tgz ];then
    tar xf $CYCLECLOUD_SPEC_PATH/files/espresso-5.4.0.centos71.intel.tgz -C /mnt/resource 
fi
