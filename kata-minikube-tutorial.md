# Kata Containers with Minikube Setup Guide

This guide walks through setting up **Kata Containers** on **Minikube** using the `kvm2` driver. 
It was tested with **Kata Containers v3.21.0** and works fine up to running an example pod.

---

## Prerequisites
Before you begin, ensure your system supports **KVM** virtualization.  
You can verify this by running:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

If the output is greater than `0`, your CPU supports virtualization.

---

## Installation Steps

### 0. Install KVM2

Follow the official Ubuntu KVM installation guide:  
🔗 [https://help.ubuntu.com/community/KVM/Installation](https://help.ubuntu.com/community/KVM/Installation)

Make sure `libvirt` and `virt-manager` are installed and properly configured.

---

### 1. Install Kata Containers Runtime

Run **Alex’s guide** to install the Kata runtime.  
Ensure that the runtime binaries and configuration files are correctly set up.

---

### 2. Install Minikube

Follow the Minikube installation guide:  
🔗 [https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download)

Once installed, verify it by running:

```bash
minikube version
```

---

### 3. Install kubectl

Follow the official Kubernetes `kubectl` installation guide:  
🔗 [https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

> ⚠️ **Note:**  
> Without `kubectl`, you’ll need to modify commands in the Kata setup documentation.

Check your installation:

```bash
kubectl version --client
```

---

### 4. Install Kata Containers on Minikube

Now follow the Kata Containers Minikube installation guide (v3.21.0):  
🔗 [https://github.com/kata-containers/kata-containers/blob/3.21.0/docs/install/minikube-installation-guide.md](https://github.com/kata-containers/kata-containers/blob/3.21.0/docs/install/minikube-installation-guide.md)

This tutorial works fine through all steps, including creating the Kata runtime class and running an example pod.

## ✅ Verification

To confirm everything is working, you can list your available runtimes:

```bash
kubectl get runtimeclasses
```

You should see a runtime class named **kata**.

Then, try running the example pod from the Kata Containers documentation.
