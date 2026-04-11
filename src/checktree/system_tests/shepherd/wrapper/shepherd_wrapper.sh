#!/bin/sh

ARCH=`$SGE_ROOT/util/arch`
SHEPHERD="$SGE_ROOT/bin/$ARCH/sge_shepherd"
exec "$SHEPHERD" "$@"
