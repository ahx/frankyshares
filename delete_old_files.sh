#!/usr/bin/env bash
# deletes uploaded files older than 2 days
#
find ./public/files/* -type d -mtime +2  -exec rm -rf "{}" ";"
