#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../envs/dev"

t0=$(date +%s)
terraform destroy -auto-approve
t1=$(date +%s)
terraform apply -auto-approve
t2=$(date +%s)

echo "Destroy: $((t1-t0))s | Apply: $((t2-t1))s"
../../scripts/smoke_test.sh "$(terraform output -raw app_url)"
t3=$(date +%s)
echo "Total incl. app ready: $((t3-t0))s"
echo "NOTE: confirm the new SNS subscription email."
