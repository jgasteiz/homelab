#!/bin/bash
set -e

kubectl port-forward svc/argocd-server --namespace argocd --context minikube 8080:443