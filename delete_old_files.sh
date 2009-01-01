#!/usr/bin/env bash
# deletes uploaded files older than 2 days
#
cd `dirname $0` && 
find ./public/files/* -type d -mtime +2  -exec rm -rf "{}" ";"