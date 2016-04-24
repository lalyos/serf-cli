#!/bin/bash

echo
echo ========= $(date +%H:%M:%S)
for v in ${!SERF*}; do
  echo $v=${!v}
done
echo === BODY
cat
echo =========
