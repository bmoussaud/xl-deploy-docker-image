#!/usr/bin/env bash
kubectl apply -n xebialabs -f xldeploy-configmap.yaml
kubectl describe  cm -n xebialabs xldeploy-config
kubectl apply -n xebialabs -f xldeploy-deployment.yaml
kubectl apply -n xebialabs -f xldeploy-service.yaml
