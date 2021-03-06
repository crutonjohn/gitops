<h1 align="center">
  It's My k8s in a Box
  <br />
  <br />
  <img src="https://i.imgur.com/p1RzXjQ.png">
</h1>
<br />
<div align="center">

[![Discord](https://img.shields.io/badge/discord-chat-7289DA.svg?maxAge=60&style=flat-square)](https://discord.gg/DNCynrJ)

</div>

---

# :book:&nbsp; Overview

Welcome to my home Kubernetes cluster. This repo _is_ my Kubernetes cluster in a declarative state. [Flux](https://github.com/fluxcd/flux2) and [Helm Operator](https://github.com/fluxcd/helm-operator) watch my [clusters](./clusters/) folder and makes the changes to my cluster based on the yaml manifests.

Feel free to join our [Discord](https://discord.gg/DNCynrJ) if you have any questions.

---

# :anchor:&nbsp; k8s Distro

Currently using [k0s](https://k0sproject.io/) by way of a customized [k0s-ansible](https://github.com/movd/k0s-ansible).

---
# :speedboat:&nbsp; Deploying

1. Have a working `kubeconfig`
2. Have `flux` installed

To boostrap the cluster:

        flux bootstrap github \
        --components=source-controller,kustomize-controller,helm-controller,notification-controller \
        --path=clusters/env/production \
        --version=latest \
        --owner=crutonjohn \
        --repository=gitops

---
## :computer:&nbsp; Hardware Configuration

_All my nodes below are running bare metal Ubuntu 20.04.x_

| Device                  | Count | OS Disk Size            | Data Disk Size                           | Ram  | Purpose |
|-------------------------|-------|-------------------------|------------------------------------------|------|---------|
| Raspberry Pi 4          | 3     | 120GB (USB Booting SSD) | N/A                                      | 4 GB | k8s Control Plane |
| Dell R610               | 3     | 2x 120GB SSD (RAID1)    | 2x 1TB HDD (RAID0, longhorn)             | 40GB | k8s Workers |

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
| sshfs-media              | 192.168.130.104 |
| loki-promtail-syslog     | 192.168.130.105 |
| syslog-ng                | 192.168.130.106 |
| minecraft                | 192.168.130.107 |
| home-assistant           | 192.168.130.108 |
| vernemq                  | 192.168.130.109 |

---

## :handshake:&nbsp; Thanks

A lot of inspiration for this repo came from the following people:

- [billimek/k8s-gitops](https://github.com/billimek/k8s-gitops)
- [carpenike/k8s-gitops](https://github.com/carpenike/k8s-gitops)
- [dcplaya/k8s-gitops](https://github.com/dcplaya/k8s-gitops)
- [rust84/k8s-gitops](https://github.com/rust84/k8s-gitops)
- [blackjid/homelab-gitops](https://github.com/blackjid/homelab-gitops)
- [bjw-s/k8s-gitops](https://github.com/bjw-s/k8s-gitops)
- [nlopez/k8s_home](https://github.com/nlopez/k8s_home)
- [onedr0p/home-cluster](https://github.com/onedr0p/home-cluster)
