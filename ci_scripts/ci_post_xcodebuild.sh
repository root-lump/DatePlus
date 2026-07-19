#!/bin/zsh

# Xcode Cloud auto-discovers lifecycle scripts only in the repository-root
# ci_scripts directory.
if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
  readonly testflight_dir_path="../TestFlight"
  mkdir -p "$testflight_dir_path"
  # Xcode Cloud uses a shallow checkout; deepen it before collecting the latest
  # five commit subjects for English TestFlight notes.
  git fetch --deepen 5
  git log -5 --pretty=format:"%s" >! "$testflight_dir_path/WhatToTest.en-US.txt"
fi
