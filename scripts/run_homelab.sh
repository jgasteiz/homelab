#!/bin/bash
set -e

kubectl port-forward svc/homelab --namespace default --context minikube 8081:80
