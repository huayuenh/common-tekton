#!/bin/bash

if [ -z $1 ]; then
  echo "Missing task name"
  exit 1
fi

echo "Setup test pipeline for $1"

TASK_NAME=$1

mkdir -p $TASK_NAME

FILES=./.template/*

for f in $FILES
do
  file="./$TASK_NAME/${f##*/}"
  echo "Processing $file ..."
  # take action on each file. $f store current file name
  sed -e "s;%TASK_NAME%;$TASK_NAME;g" $f > $file
done



# sed -e "s;%TASK_NAME%;$1;g" ./.template/trigger.yaml
