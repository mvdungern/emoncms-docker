#!/bin/bash
git config --global --add safe.directory '*'
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf