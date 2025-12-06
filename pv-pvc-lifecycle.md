# CNFS PV/PVC Lifecycle Test (Task 21)

## Goal
Verify that:
1. Our CSI driver can provision and mount a volume.
2. A pod can write data to the volume.
3. A different pod can read the same data using the same PVC.

## Prerequisites
- CSI driver deployed (controller + node)
- StorageClass `cnfs-kata-nfs` created
- PVC `cnfs-kata-nfs-pvc` created and in `Bound` state

## Test Steps

1. **Deploy writer pod**
   - Pod name: `cnfs-write-pod`
   - Mounts PVC: `cnfs-kata-nfs-pvc` at `/data`
   - Writes the string `hello-from-cnfs` into `/data/test.txt`

2. **Verify write succeeded**
   - Command:
     ```bash
     kubectl exec cnfs-write-pod -- cat /data/test.txt
     ```
   - Expected output: `hello-from-cnfs`

3. **Delete writer pod**
   - Command:
     ```bash
     kubectl delete pod cnfs-write-pod
     ```

4. **Deploy reader pod**
   - Pod name: `cnfs-read-pod`
   - Mounts the same PVC: `cnfs-kata-nfs-pvc` at `/data`
   - Reads `/data/test.txt` and prints contents to logs

5. **Verify read succeeded**
   - Command:
     ```bash
     kubectl logs cnfs-read-pod
     ```
   - Expected logs contain: `hello-from-cnfs`

6. **Cleanup**
   - Optionally:
     ```bash
     kubectl delete pod cnfs-read-pod
     # PVC and StorageClass can be kept for future tests
     ```
