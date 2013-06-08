#!/bin/bash
rvm_path=~/.rvm
source ~/.rvm/scripts/rvm
rvm use 1.9.2

base_path=`dirname $0`
cd $base_path

ruby passo.rb
