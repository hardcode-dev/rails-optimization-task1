#!/usr/bin/env bash

gunzip data_large.txt.gz -k
head -n 1000 data_large.txt > data_1k.txt
head -n 2000 data_large.txt > data_2k.txt
head -n 4000 data_large.txt > data_4k.txt
head -n 8000 data_large.txt > data_8k.txt
head -n 16000 data_large.txt > data_16k.txt
head -n 32000 data_large.txt > data_32k.txt
head -n 64000 data_large.txt > data_64k.txt
head -n 128000 data_large.txt > data_128k.txt
head -n 256000 data_large.txt > data_256k.txt