#!/bin/sh
set -eu

g++ -march=native -mtune=native -std=gnu++11 -O3 -flto -fomit-frame-pointer -fwrapv -Wno-attributes -Dmodulus_bytes_val='17.125' -Dlimb_t=uint32_t -Dq_mpz='(1_mpz<<137) - 13' -Dmodulus_limbs='8' -Dlimb_weight_gaps_array='{18,17,17,17,17,17,17,17}' -Dmodulus_array='{0x01,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xf3}' "$@"