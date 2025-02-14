#!/bin/zsh

KEY=3132333435360000000000000000000000000000000000000000000000000000
IV1=3710b103bf05be90e33b2bd9df151ac0
IV2=00000000000000000000000000000000

mkdir temp
rm temp/ecb-*

openssl enc -e -aes-256-ecb \
  -K ${KEY} -iv ${IV1} -nosalt \
  -in in.txt -out temp/ecb-1-encoded.txt

xxd -plain temp/ecb-1-encoded.txt

openssl enc -d -aes-256-ecb \
  -K ${KEY} -iv ${IV2} -nosalt \
  -in temp/ecb-1-encoded.txt -out temp/ecb-2-decoded.txt

cat temp/ecb-2-decoded.txt
