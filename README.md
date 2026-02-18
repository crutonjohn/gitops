<h1 align="center">
  It's My k8s in a Box
  <br />
  <br />
  <img src="https://i.imgur.com/p1RzXjQ.png">
</h1>
<br />
<div align="center">

[![Discord](https://img.shields.io/badge/discord-chat-7289DA.svg?maxAge=60&style=flat-square)](https://discord.gg/home-operations)

</div>

---

# :book:&nbsp; Overview

This repo _is_ my Kubernetes cluster in a declarative state. [Flux](https://github.com/fluxcd/flux2) and [Helm Operator](https://github.com/fluxcd/helm-operator) watch my [clusters](./clusters/) folder and makes the changes to my cluster based on the yaml manifests. [Renovate](https://github.com/renovatebot/renovate) auto updates images and helm charts based on upstream changes.

Feel free to join our [Discord](https://discord.gg/home-operations) if you have any questions.

---

# :anchor:&nbsp; k8s Distro

Currently using [talos](https://talos.dev) by PXE booting for initial install. PXE server is a local [netboot.xyz](https://netboot.xyz) container running on my [NixOS-based NAS](https://github.com/crutonjohn/nix/tree/main/hosts/perturabo).

---
# :speedboat:&nbsp; Deploying the cluster

## Rough Outline

1. Boot machines
2. They either start Talos from disk if already installed, or PXE boot to the installer.
3. Get kubeconfig: `talosctl kubeconfig`
4. Deploy Cilium CNI to `kube-system` namespace:
  - `helm install cilium cilium/cilium -f provision/cilium/production.yaml`

## Using go-task

- Boot machines
  - They boot to Talos via PXE
  - If there is a pre-existing Talos install, nodes just boot to the disk
  - PXE server configurations: [NixOS PXE](https://github.com/crutonjohn/nix/tree/fd1599ffc817f0e4ca02ca7ec4ae10f9628cddee/hosts/perturabo/podman/netbootxyz)
- Machines should boot, install, and set up the cluster
- `task talos:gen-talosconfig` outputs a talosconfig to `gitignore/talosconfig`
- `task talos:kubeconfig` outputs a kubeconfig to `gitignore/kubeconfig`
- `task talos:install-cilium` installs cilium CNI to the cluster
- `task flux:bootstrap` bootstraps the cluster with the flux configs in this repo

---
## :computer:&nbsp; Hardware Configuration

_All my nodes below are running bare metal Talos_

| Device                  | Count | OS Disk Size            | Data Disk Size                           | Ram  | Purpose |
|-------------------------|-------|-------------------------|------------------------------------------|------|---------|
| [Bmax B3 (Intel N5095)](https://www.bmaxit.com/Maxmini-B3-New-pd714800688.html)  | 3     | 256GB SSD | N/A                                      | 8 GB | k8s Control Plane |
| [Minisforum MS-01 (Intel 12600H)](https://store.minisforum.com/products/minisforum-ms-01)          | 3     | 1x 1TB NVME            | 1x 2TB NVME (rook-ceph)                   | 64GB | k8s Workers |
| Supermicro [MBD-H12SSL-NT-B](https://www.supermicro.com/en/products/motherboard/H12SSL-NT) with [AMD EPYC 7282](https://www.amd.com/en/support/downloads/drivers.html/processors/epyc/epyc-7002-series/amd-epyc-7282.html) | 1 | 1x 1TB NVME | N/A                                      | 128GB | Ceph Bulk Storage & AI/ML |
| Supermicro 216BE1C-R741JBOD         | 1     | N/A                     | 24x 1TB SSD                              | N/A  | Disk Shelf |


## :computer:&nbsp; Supporting Infrastructure

- [Opnsense DEC2750](https://shop.opnsense.com/product/dec2750-opnsense-rack-security-appliance/) Router
- [TP-Link TL-SG3428XMP](https://www.tp-link.com/us/business-networking/omada-sdn-switch/tl-sg3428xmp/) Core Switch
- [TP-Link SX3206HPP](https://www.omadanetworks.com/us/business-networking/omada-switch-access-max/sx3206hpp/) Garage Distribution
- [TP-Link SX3008F](https://www.tp-link.com/us/business-networking/managed-switch/tl-sx3008f/) 10Gig Distribution
- [TP-Link SG2210XMP-M2](https://www.omadanetworks.com/my/business-networking/omada-switch-l3-l2-managed/sg2210xmp-m2/) 2.5Gig Managed Access
- x3 [TP-Link EAP725-Wall](https://www.tp-link.com/us/business-networking/omada-wifi-wall-plate/eap725-wall/) Wi-Fi 7 Access Points
- x2 [TP-Link TL-SG105S-M2](https://www.tp-link.com/us/business-networking/soho-switch-unmanaged/tl-sg105s-m2/) Desktop Access Switch
  - x2 [TL-PD30G-M2](https://www.tp-link.com/us/business-networking/soho-accessory/tl-pd30g-m2/) 2.5Gig PoE Splitter for power

---

## :memo:&nbsp; IP addresses

Can generally be viewed at [settings.yaml](./clusters/secrets/generic/settings.yaml)

---
## :handshake:&nbsp; Community

A lot of inspiration for my cluster came from the people that have shared their cluster configuration with me. Thanks to all the people who donate their time to the Home Operations community. Join us on [Discord](https://discord.gg/home-operations)!
