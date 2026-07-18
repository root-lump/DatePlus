#!/bin/zsh

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
  readonly testflight_dir_path="../TestFlight"
  mkdir -p "$testflight_dir_path"
  git fetch --deepen 5
  git log -5 --pretty=format:"%s" >! "$testflight_dir_path/WhatToTest.en-US.txt"
fi
