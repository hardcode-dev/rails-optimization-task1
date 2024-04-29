#!/bin/sh
ruby work.rb  | ps aux | grep work.rb | grep -v grep | awk '{print $2}' | xargs sudo rbspy record --pid