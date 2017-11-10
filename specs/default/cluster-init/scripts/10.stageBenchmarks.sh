#! /bin/bash -e

if [ test -f $CYCLECLOUD_SPEC_PATH/files/qe_benchmark.tar.gz ]; then
    cp $CYCLECLOUD_SPEC_PATH/files/qe_benchmark.tar.gz /shared
fi
