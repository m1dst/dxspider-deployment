#!/bin/bash
#
# DXSpider entry point
#
SPIDER_INSTALL_DIR=${SPIDER_INSTALL_DIR:-/spider}

# generate config file using parameters passed via environment variables
cat << EOF > ${SPIDER_INSTALL_DIR}/local/Listeners.pm
package main;

use vars qw(@listen);

@listen = (
    ["0.0.0.0", ${CLUSTER_PORT:-7300}],
);

1;
EOF
sed -e 's/\(\$mycall[[:space:]]*=[[:space:]]*\).*$/\1"'${CLUSTER_CALLSIGN}'";/' \
    -e 's/\(\$myname[[:space:]]*=[[:space:]]*\).*$/\1"'"${CLUSTER_SYSOP_NAME}"'";/' \
    -e 's/\(\$myalias[[:space:]]*=[[:space:]]*\).*$/\1"'${CLUSTER_SYSOP_CALLSIGN}'";/' \
    -e 's/\(\$mylatitude[[:space:]]*=[[:space:]]*\).*$/\1'${CLUSTER_LATITUDE:-0}';/' \
    -e 's/\(\$mylongitude[[:space:]]*=[[:space:]]*\).*$/\1'${CLUSTER_LONGITUDE:-0}';/' \
    -e 's/\(\$mylocator[[:space:]]*=[[:space:]]*\).*$/\1"'$(echo ${CLUSTER_LOCATOR} | tr '[a-z]' '[A-Z]')'";/' \
    -e 's/\(\$myemail[[:space:]]*=[[:space:]]*\).*$/\1"'$(echo ${CLUSTER_SYSOP_EMAIL} | sed 's/\@/\\@/g')'";/' \
    -e 's/\(\$mybbsaddr[[:space:]]*=[[:space:]]*\).*$/\1"'$(echo ${CLUSTER_SYSOP_BBS_ADDRESS} | sed 's/\@/\\@/g')'";/' \
    < ${SPIDER_INSTALL_DIR}/perl/DXVars.pm.issue > ${SPIDER_INSTALL_DIR}/local/DXVars.pm && \
cd ${SPIDER_INSTALL_DIR}/perl && \
./create_sysop.pl && \
./cluster.pl 

