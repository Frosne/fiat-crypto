#!/bin/sh
set -eu

/usr/bin/env python3 "$@" -Dq='2**285 - 9' -Dmodulus_bytes='19' -Da24='121665'
