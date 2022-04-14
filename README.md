<h1 align="center">
  It's My k8s in a Box
  <br />
  <br />
  <img src="https://i.imgur.com/p1RzXjQ.png">
</h1>
<br />
<div align="center">

[![Discord](https://img.shields.io/badge/discord-chat-7289DA.svg?maxAge=60&style=flat-square)](https://discord.gg/k8s-at-home)

</div>

---

# :book:&nbsp; Overview

This repo _is_ my Kubernetes cluster in a declarative state. [Flux](https://github.com/fluxcd/flux2) and [Helm Operator](https://github.com/fluxcd/helm-operator) watch my [clusters](./clusters/) folder and makes the changes to my cluster based on the yaml manifests. [Renovate](https://github.com/renovatebot/renovate) auto updates images and helm charts based on upstream changes.

Feel free to join our [Discord](https://discord.gg/k8s-at-home) if you have any questions.

---

# :anchor:&nbsp; k8s Distro

Currently using [k3s](https://k3s.io) by way of a customized [template-cluster-k3s](https://github.com/k8s-at-home/template-cluster-k3s) [ansible playbook](https://github.com/k8s-at-home/template-cluster-k3s/tree/main/provision/ansible).

---
# :speedboat:&nbsp; Deploying k3s

1. `pip install pipenv`
2. `pipenv install`
3. `pipenv run gilt overlay`
4. `pipenv run ansible-playbook -i provision/ansible/inventory/inventory.yaml provision/ansible/playbooks/k3s-install.yaml`
6. `k label nodes k-node1.crutonjohn.com k-node2.crutonjohn.com k-node3.crutonjohn.com k-node4.crutonjohn.com k-node5.crutonjohn.com crutonjohn.com/rook=true`
7. `kubectl taint nodes k-master01.crutonjohn.com k-master02.crutonjohn.com k-master03.crutonjohn.com crutonjohn=control-plane:NoSchedule`

## Installing and bootstrapping flux

1. Have a working `kubeconfig`
2. Have `flux` installed
3. Have `GITHUB_TOKEN` env var set to a Github PAT
4. To boostrap the cluster:

        flux bootstrap github \
        --components=source-controller,kustomize-controller,helm-controller,notification-controller \
        --path=clusters/env/production \
        --version=latest \
        --owner=crutonjohn \
        --repository=gitops

5. `sops -d sops-secret.enc.yaml | kubectl apply -f -`

### if you need storage :)

`kustomize build clusters/core/pvc/`

---
## :computer:&nbsp; Hardware Configuration

_All my nodes below are running bare metal Ubuntu 20.04.x_

| Device                  | Count | OS Disk Size            | Data Disk Size                           | Ram  | Purpose |
|-------------------------|-------|-------------------------|------------------------------------------|------|---------|
| Raspberry Pi 4          | 3     | 120GB (USB Booting SSD) | N/A                                      | 4 GB | k8s Control Plane |
| HP 800 G3 Mini          | 2     | 1x 120GB SSD            | 1x 1TB M.2 (rook-ceph)                   | 32GB | k8s Workers |
| Dell 7040 Micro         | 3     | 1x 500B HDD             | 1x 1TB M.2 SSD (rook-ceph)               | 32GB | k8s Workers |

## :computer:&nbsp; Supporting Infrastructure

| Device                  | Count | OS Disk Size            | Data Disk Size                           | Ram  | Purpose |
|-------------------------|-------|-------------------------|------------------------------------------|------|---------|
| Supermicro CSE-512B     | 1     | 1x 500GB Spinning Rust  | N/A                                      | 32GB | ZFS on Linux Host |
| Xyratex HB-1235         | 1     | N/A                     | 10x 4TB HDD                              | N/A  | ZFS Disk Shelf |

## :computer:&nbsp; Testing Cluster

| Device                  | Count | OS Disk Size            | Data Disk Size                           | Ram  | Purpose        |
|-------------------------|-------|-------------------------|------------------------------------------|------|----------------|
| Raspberry Pi 4          | 3     | 120GB (USB Booting SSD) | N/A                                      | 4 GB | k8s Test Boxes |


---

## :memo:&nbsp; IP addresses

_This table is a reference to IP addresses in my deployments and may not be fully up-to-date_

| Deployment               | Address        |
|--------------------------|----------------|
| nginx-ingress (external) | 192.168.130.100 |
| nginx-ingress (internal) | 192.168.130.101 |
| blocky                   | 192.168.130.102 |
| unifi                    | 192.168.130.103 |
| home-assistant           | 192.168.130.108 |
| emqx                     | 192.168.130.109 |
| stackrox                 | 192.168.130.111 |
| istio-test               | 192.168.130.112 |

---
## :handshake:&nbsp; Community

Thanks to all the people who donate their time to the [Kubernetes @Home](https://github.com/k8s-at-home/) community. Join us at https://discord.gg/k8s-at-home

A lot of inspiration for my cluster came from the people that have shared their clusters over at [awesome-home-kubernetes](https://github.com/k8s-at-home/awesome-home-kubernetes)
