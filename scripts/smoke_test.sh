#!/usr/bin/env bash
set -u
URL="${1:?usage: smoke_test.sh <app_url>}"
check() {  # name, path, expected substring
  for i in $(seq 1 30); do
    out=$(curl -s --max-time 5 "$URL$2" || true)
    if [[ "$out" == *"$3"* ]]; then echo "PASS  $1"; return 0; fi
    sleep 10
  done
  echo "FAIL  $1 (got: $out)"; return 1
}
rc=0
check nginx /nginx-health ok || rc=1
check app   /health OK || rc=1
check hello "/hello?name=Terraform" "Hello, Terraform!" || rc=1
exit $rc
