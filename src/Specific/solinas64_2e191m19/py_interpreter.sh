#!/bin/sh
set -eu

/usr/bin/env python3 "$@" -Dq='2**191 - 19' -Dmodulus_bytes='38.2' -Da24='121665'
