#!/bin/sh

#killall -q polybar
echo "---" >>/tmp/polybar_additional.log
polybar additional >>/tmp/polybar_additional.log 2>&1
