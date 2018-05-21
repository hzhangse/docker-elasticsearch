#!/bin/bash

cat /fuse/bin/alluxio-site.properties.template | sed \
  -e "s|{{alluxio.master}}|${alluxio.master}|g" \
   > /fuse/bin/alluxio-site.properties


