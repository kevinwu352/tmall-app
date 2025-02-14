#!/bin/zsh

KEY=3132333435360000000000000000000000000000000000000000000000000000
IV=a36700a0ddccc3c884c4c725b71e9872

mkdir temp
rm temp/cbc-*

openssl enc -e -aes-256-cbc \
  -K ${KEY} -iv ${IV} -nosalt \
  -in in.txt -out temp/cbc-1-encoded.txt

xxd -plain temp/cbc-1-encoded.txt

openssl enc -d -aes-256-cbc \
  -K ${KEY} -iv ${IV} -nosalt \
  -in temp/cbc-1-encoded.txt -out temp/cbc-2-decoded.txt

cat temp/cbc-2-decoded.txt
