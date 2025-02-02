#!/bin/bash

# Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Run pub get to fetch packages.
dart pub get
dart pub global activate coverage

# Run the tests.
# echo "Running tests..."
# dart run test --reporter expanded

# Gather coverage and upload to Coveralls.
OBS_PORT=9292
echo "Collecting coverage on port $OBS_PORT..."

# Run the coverage collector to generate the JSON coverage report.
dart pub global run coverage:collect_coverage \
  --port=$OBS_PORT \
  --out=var/coverage.json \
  --wait-paused \
  --resume-isolates &

# Start tests in one VM.
dart \
  --disable-service-auth-codes \
  --enable-vm-service=$OBS_PORT \
  --pause-isolates-on-exit \
  test/test_all.dart 

echo "Generating LCOV report..."
format_coverage \
  --lcov \
  --in=var/coverage.json \
  --out=var/lcov.info \
  --packages=.packages \
  --report-on=lib