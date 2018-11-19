#!/usr/bin/env bash
kubectl apply -f postgres-configmap.yaml -n xebialabs
kubectl apply -f postgres-storage.yaml -n xebialabs
kubectl apply -f postgres-deployment.yaml  -n xebialabs
kubectl apply -f postgres-service.yaml  -n xebialabs

