# edit spec.trafficPolicy.tls.mode section, changing its value from ISTIO_MUTUAL to DISABLE 
kubectl edit destinationrule -n kubeflow ml-pipeline
kubectl edit destinationrule -n kubeflow ml-pipeline-ui


