#!/usr/bin/env bash
set -euo pipefail

echo "=== CNFS Automated Demo (Flat Directory Version) ==="

#############################################
# 1. Apply CSI Driver Components
#############################################

echo "[1/6] Applying CSI driver manifests..."

kubectl apply -f csi-driver.yaml
kubectl apply -f csi-controller-rbac.yaml
kubectl apply -f csi-controller-deployment.yaml
kubectl apply -f csi-node-rbac.yaml
kubectl apply -f csi-node-daemonset.yaml

echo "Waiting for CSI controller and node pods to be Ready..."
kubectl wait --for=condition=Ready pod -l app=cnfs-csi-controller -n kube-system --timeout=180s || true
kubectl wait --for=condition=Ready pod -l app=cnfs-csi-node -n kube-system --timeout=180s || true


#############################################
# 2. Apply StorageClass and PVC
#############################################

echo "[2/6] Applying StorageClass & PVC..."

kubectl apply -f storageclass-cnfs.yaml
kubectl apply -f pvc-cnfs.yaml

echo "Waiting for PVC to reach Bound state..."
kubectl wait pvc cnfs-kata-nfs-pvc --for=jsonpath='{.status.phase}'=Bound --timeout=180s || {
  echo "PVC did not reach Bound state in time."; exit 1;
}


#############################################
# 3. Deploy Writer Pod
#############################################

echo "[3/6] Deploying writer pod..."
kubectl apply -f cnfs-write-pod.yaml

echo "Waiting for writer pod to become Ready..."
kubectl wait pod cnfs-write-pod --for=condition=Ready --timeout=180s || true

echo "Checking if writer pod successfully wrote the file..."
if kubectl exec cnfs-write-pod -- cat /data/test.txt 2>/dev/null; then
  echo "[Writer] Successfully wrote file."
else
  echo "[Writer] FAILED to write file."
fi


#############################################
# 4. Switch to Reader Pod
#############################################

echo "[4/6] Deleting writer pod..."
kubectl delete pod cnfs-write-pod --ignore-not-found=true

echo "[5/6] Deploying reader pod..."
kubectl apply -f cnfs-read-pod.yaml

echo "Waiting for reader pod to become Ready..."
kubectl wait pod cnfs-read-pod --for=condition=Ready --timeout=180s || true

echo "Reader pod logs:"
kubectl logs cnfs-read-pod || true


#############################################
# 5. Summary
#############################################

echo
echo "=== CNFS PV/PVC Lifecycle Test Completed ==="
echo "If the reader pod printed 'hello-from-cnfs', persistence works."
echo
echo "Cleanup with:"
echo "  kubectl delete pod cnfs-read-pod"
echo "  kubectl delete pvc cnfs-kata-nfs-pvc"
echo

exit 0
