#!/bin/sh

if [ $# -lt 3 ]
then
    echo "$0 <keyfile> <in> <out>"
    exit 1
fi


keyfile="$1"
keylen='200'
enc_alg='-aes-256-ctr'
input="$2"
output="$3"

if [ ! -e $output ]
then
    mkdir -p $output
fi

for key in $(ls $input | grep '\.key')
do
    enc_file="${input%/}/${key%.key}.tar.gz.enc"
    out_file="${output%/}/${key%.key}.tar.gz"
    key="${input%/}/$key"

    temp=$(mktemp)
    
    openssl rsautl -decrypt -inkey $keyfile < $key > $temp # dec key
    openssl enc -d $enc_alg -kfile $temp < $enc_file > $out_file # dec data
    tar xzf $out_file -C $output
    rm -f $out_file
    
    shred -uzn 10 $temp
done
