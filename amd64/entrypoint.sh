#!/bin/sh
set -e

# check if there was a command passed
if [ -n "$1" ] ; then
  echo "executing $@"
  # execute it
  exec "$@"
else
  echo "executing /lib/systemd/systemd"
  /lib/systemd/systemd
fi
