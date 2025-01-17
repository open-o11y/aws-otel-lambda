#!/bin/bash

: <<'END_DOCUMENTATION'
`patch-upstream.sh`

This script patches the git submodule folder `opentelemetry-lambda` with ADOT
recommended configuration. The upstream repo is vendor agnostic, but we modify
it slightly to create Lambda Layers that should help OpenTelemetry users trace
their Lambdas with Lambda Layers configured to export to the X-Ray backend.

END_DOCUMENTATION

# Patch some upstream components with ADOT specific components
cp -rf adot/* opentelemetry-lambda/

# Move to the upstream OTel Lambda Collector folder where we will build a
# collector used in each Lambda layer
cd opentelemetry-lambda/collector

# patch collector startup to remove HTTP and S3 confmap providers
# and set ADOT-specific BuildInfo
patch -p2 < ../../collector.patch

# Replace OTel Collector with ADOT Collector
go mod edit -replace github.com/open-telemetry/opentelemetry-lambda/collector/lambdacomponents=github.com/aws-observability/aws-otel-collector/pkg/lambdacomponents@v0.25.1

# Replace the prometheus import to avoid the mismatch in go dependency
# see https://github.com/aws-observability/aws-otel-collector/blob/v0.22.0/pkg/lambdacomponents/go.mod#L66
go mod edit -replace github.com/prometheus/prometheus@v1.8.2-0.20220117154355-4855a0c067e2=github.com/prometheus/prometheus@v0.40.5

rm -fr go.sum
go mod tidy
