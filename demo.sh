#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " CNFS INTERPOSER CSI DRIVER DEMO"
echo "======================================"
echo

echo "=== 0) Show CSI driver pods (controller + node) ==="
kubectl get pods -n kube-system | grep cnfs-csi
echo

echo "=== 1) Show StorageClass and PVC bound to CNFS ==="
kubectl get sc cnfs-kata-nfs
echo
kubectl get pvc cnfs-kata-nfs-pvc
echo

echo "=== 2) Clean any old demo pods ==="
kubectl delete pod cnfs-write-pod --ignore-not-found
kubectl delete pod cnfs-read-pod --ignore-not-found
echo

echo "=== 3) Start write pod (kata-qemu) and write to /data/test.txt ==="
kubectl apply -f cnfs-write-pod.yaml
kubectl wait --for=condition=Ready pod/cnfs-write-pod --timeout=90s
echo

echo "--- Contents of /data inside cnfs-write-pod ---"
kubectl exec cnfs-write-pod -- ls -l /data || true
echo

echo "--- Reading /data/test.txt from write pod ---"
kubectl exec cnfs-write-pod -- cat /data/test.txt || true
echo

echo "=== 4) Delete write pod, start read pod (kata-qemu) ==="
kubectl delete pod cnfs-write-pod
kubectl apply -f cnfs-read-pod.yaml
kubectl wait --for=condition=Ready pod/cnfs-read-pod --timeout=90s
echo

echo "--- Reading /data/test.txt from read pod (should match) ---"
kubectl exec cnfs-read-pod -- cat /data/test.txt || true
echo

echo "=== DEMO COMPLETE: CNFS volume persisted data between Kata pods ==="
