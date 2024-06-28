#!/bin/bash
NOWIPADDR="/tmp/nowipaddr"
GETIPADDR=`curl ip.p3terx.com | awk '{if(NR==1) print}'`

if [ -f $NOWIPADDR ]; then
  if [ $GETIPADDR = $(< $NOWIPADDR) ]; then
    echo "ip is not changed."
  else
    echo $GETIPADDR > $NOWIPADDR
    echo "ip is changed. Notification is sent. curr ip $GETIPADDR"
    echo $GETIPADDR
  fi
else
  echo $GETIPADDR > $NOWIPADDR
  echo "ip is set now. Notification is sent. curr ip $GETIPADDR"
  echo $GETIPADDR
fi

