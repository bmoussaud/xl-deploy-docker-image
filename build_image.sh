#!/usr/bin/env bash
docker build --build-arg XLD_VERSION=8.2.1 --tag bmoussaud/xl-deploy-with-db:8.2.8  -f debian-slim/Dockerfile .
