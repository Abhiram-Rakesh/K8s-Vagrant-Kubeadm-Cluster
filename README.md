# Kubernetes Cluster using Vagrant & kubeadm

---

## Overview

This project provisions a **fully functional, multi-node Kubernetes cluster** locally using **Vagrant**, **VirtualBox**, and **kubeadm**.

The goal of this project is to simulate a **production-style Kubernetes environment** on local infrastructure, focusing on:

- Infrastructure reproducibility
- Proper Kubernetes bootstrapping
- Real-world debugging and failure handling
- DevOps best practices using Infrastructure as Code (IaC)

The cluster is designed to be **portable**, meaning it can be spun up on any compatible Windows or Linux machine using a single command:

```
vagrant up
```

---

## Architecture

### Cluster Topology

- **1 Control Plane Node**
- **2 Worker Nodes**

### Node Details

```
| Node Name        | Role            | IP Address        |
|------------------|-----------------|-------------------|
| k8s-master       | Control Plane   | 192.168.56.10     |
| k8s-worker-1     | Worker Node     | 192.168.56.11     |
| k8s-worker-2     | Worker Node     | 192.168.56.12     |
```

### Technology Stack

- **Host Provisioning**: Vagrant
- **Hypervisor**: VirtualBox
- **Guest OS**: Ubuntu 22.04 LTS
- **Container Runtime**: containerd
- **Kubernetes Bootstrap**: kubeadm
- **Networking (CNI)**: Calico

### High-Level Flow

```
Host Machine
|
|-- Vagrant
|
|-- k8s-master (API Server, Scheduler, Controller Manager, etcd)
|-- k8s-worker-1 (Workload Node)
|-- k8s-worker-2 (Workload Node)
```

---

## Key Design Decisions

### 1. kubeadm-based Cluster

- Mirrors real-world Kubernetes bootstrapping.
- Avoids managed abstractions (EKS/AKS/GKE) to gain deeper understanding.

### 2. containerd as Runtime

- Industry standard container runtime.
- Required explicit systemd cgroup alignment for kubelet compatibility.

### 3. Calico CNI

- Production-grade networking solution.
- Supports network policies and scalable pod networking.

### 4. Host-Only Networking

- Ensures deterministic node-to-node communication.
- Avoids dependency on external networks.

### 5. Script-Based Provisioning

- Modular shell scripts for:
  - OS preparation
  - container runtime installation
  - Kubernetes component installation
- Improves maintainability and debugging.

---

## Prerequisites

### Host Machine Requirements

- **Installed Software**
  - VirtualBox
  - Vagrant
  - Git

- **Hardware**
  - Minimum 8 GB RAM (16 GB recommended)
  - CPU virtualization enabled (VT-x / AMD-V)

### Notes

- On Windows, Hyper-V, VBS, and host-only network adapters may interfere with VirtualBox.
- Linux hosts generally provide a smoother experience.

---

## Installation Instructions

### 1. Clone the Repository

```
git clone https://github.com/Abhiram-Rakesh/K8s-Vagrant-Kubeadm-Cluster.git
cd k8s-vagrant-kubeadm-cluster
```

### 2. Bring Up the Cluster

```
vagrant up
```

This command will: 
  - Create 3 Ubuntu VMs
  - Configure networking
  - Install containerd
  - Install Kubernetes components
  - Initialize the control plane
  - Deploy Calico
  - Join worker nodes to the cluster

### 3. Access the Cluster

```
vagrant ssh k8s-master
```

### 4. Validate the Setup

```
kubectl get nodes
kubectl get podes -n kube-system
```

Expected output:

```
k8s-master     Ready   control-plane
k8s-worker-1   Ready
k8s-worker-2   Ready
```

## Troubleshooting Guide

This project intentionally documents real-world issues encountered during setup

### Common Issues & Resolutions

#### 1. Vagrant SSH Timeout (Windows)

  - **Cause:** Corrupted VirtualBox Host-Only Network Adapter
  - **Fix:** Delete and recreate the adapter from VirtualBox Network settings

#### 2. containerd CRI Errors

  - **Cause:** Misaligned cgroup driver or corrupted runtime state
  - **Fix:** Fully reset containerd and regenerate configuration with **SystemdCgroup=true**

#### 3. kubelet TLS Bootstrap Failures

  - **Cause:** Partial kubeadm join attempts leaving stale state
  - **Fix:** Verify connectivity on port 6443, flush iptables, regenerate join token

These issues and fixes closely resemble problems seen in on-prem and bare-metal Kubernetes environments.

## Recap

This project demonstrates: 
  - End-to-end Kubernetes cluster provisioning using kubeadm
  - Practical experience with container runtimes and kubelet behavior 
  - Debugging Kubernetes networking, certificates, and node bootstrap
  - Infrastructure automation using Vagrant

