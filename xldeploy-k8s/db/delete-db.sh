#!/usr/bin/env bash
kubectl delete service postgres -n xebialabs
kubectl delete deployment postgres -n xebialabs
kubectl delete configmap postgres-config -n xebialabs
kubectl delete persistentvolumeclaim postgres-pv-claim-11 -n xebialabs
kubectl delete persistentvolume postgres-pv-volume-11 -n xebialabs

