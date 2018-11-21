#!/usr/bin/env bash
kubectl delete deployment xldeploy-deployment  -n xebialabs
kubectl delete pvc xld-pv-claim-conf  -n xebialabs
kubectl delete pvc xld-pv-claim-ext  -n xebialabs
