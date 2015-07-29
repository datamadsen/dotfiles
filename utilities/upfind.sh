#!/bin/sh

while [[ $PWD != / ]]; do
  find "$PWD"/ -maxdepth 1 "$@"
  cd ..
done
