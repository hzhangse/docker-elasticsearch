#!/bin/bash

cat /fuse/bin/alluxio-site.properties.template | sed \
  -e "s|{{alluxio_master}}|${alluxio_master}|g" \
   > /fuse/bin/alluxio-site.properties

chmod a+x /fuse/bin/alluxio-site.properties    


