#!/usr/bin/env bash
kubectl apply -f gp2-storage-class.yaml
kubectl get storageclass
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


kubectl apply -n xebialabs -f xldeploy-configmap.yaml
kubectl describe  cm -n xebialabs xldeploy-config
kubectl apply -n xebialabs -f xldeploy-storage.yaml
kubectl get pvc -n xebialabs
kubectl describe pvc xld-pv-claim-conf -n xebialabs
kubectl describe pvc xld-pv-claim-ext -n xebialabs

kubectl apply -n xebialabs -f xldeploy-deployment.yaml
kubectl describe deployment  xldeploy-deployment -n xebialabs
kubectl get pods -n xebialabs


kubectl apply -n xebialabs -f xldeploy-service.yaml
