#!/bin/sh
set -eu

/usr/bin/env python3 "$@" -Dq='2**196 - 15' -Dmodulus_bytes='49' -Da24='121665'
