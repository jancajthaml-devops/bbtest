#!/bin/sh
set -e

# check if there was a command passed
if [ "$1" ] ; then
  # execute it
  exec "$@"
else
  exec /lib/systemd/systemd
fi
