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

Currently using [k0s](https://k0sproject.io) by way of [k0sctl](https://github.com/k0sproject/k0sctl). These configurations can be viewed in [provision/k0s](./provision/k0s/).

---
# :speedboat:&nbsp; Deploying the cluster

1. `nix-shell --command 'k0sctl apply -f ./provision/k0s/production.yaml'`
2. `nix-shell --command 'k0sctl kubeconfig -c ./provision/k0s/production.yaml > ./hack/main'`
3. `sops -d provision/cilium/production.yaml | helm install cilium cilium/cilium -f -`

## Installing and bootstrapping flux

1. `nix-shell --command 'k0sctl kubeconfig -c ./provision/k0s/production.yaml > ./hack/main'`
2. Have `flux` installed (need to nixify this)
3. `set GITHUB_TOKEN ghp_Qk5eLNaaaaaaaaaaaaaaaaaaaaaaaaaaa`
4. To boostrap the cluster:

        flux bootstrap github \
        --components=source-controller,kustomize-controller,helm-controller,notification-controller \
        --path=clusters/env/production \
        --version=latest \
        --owner=crutonjohn \
        --repository=gitops

5. `sops -d sops-secret.enc.yaml | kubectl apply -f -`

### Required node labels

1. `k label nodes horus lion magnus dorn guilliman sanguinius lorgar ${FAMILY_DOMAIN}/bgp=worker`
2. `k label nodes lorgar ${FAMILY_DOMAIN}/role=nas`
3. `k label nodes dorn guilliman sanguinius ${FAMILY_DOMAIN}/rook=distributed`

---
## :computer:&nbsp; Hardware Configuration

_All my nodes below are running bare metal Ubuntu 20.04.x_

| Device                  | Count | OS Disk Size            | Data Disk Size                           | Ram  | Purpose |
|-------------------------|-------|-------------------------|------------------------------------------|------|---------|
| HP 800 G3 Mini          | 3     | 120GB SSD | N/A                                      | 32 GB | k8s Control Plane |
| Minisforum MS-01 (12600H)          | 3     | 1x 1TB NVME            | 1x 2TB NVME (rook-ceph)                   | 64GB | k8s Workers |
| Ryzen 3900x Custom     | 1     | 2x 1TB SSD  | N/A                                      | 128GB | k8s Rook-Ceph NAS |
| Supermicro 216BE1C-R741JBOD         | 1     | N/A                     | 24x 1TB SSD                              | N/A  | Disk Shelf |


## :computer:&nbsp; Supporting Infrastructure

- [Opnsense DEC2750](https://shop.opnsense.com/product/dec2750-opnsense-rack-security-appliance/) Router
- [TP-Link TL-SG3428XMP](https://www.tp-link.com/us/business-networking/omada-sdn-switch/tl-sg3428xmp/) Core Switch
- [TP-Link TL-SG3428XMP](https://www.tp-link.com/us/business-networking/omada-sdn-switch/tl-sg3428xmp/) Upstairs Distribution Switch
- [TP-Link SX3008F](https://www.tp-link.com/us/business-networking/managed-switch/tl-sx3008f/) 10Gig Distribution Switch
- x2 [TP-Link EAP660 HD](https://www.tp-link.com/us/business-networking/omada-sdn-access-point/eap660-hd/) WAPs
- [TP-Link EAP615-Wall](https://www.tp-link.com/us/business-networking/omada-wifi-wall-plate/eap615-wall/) Still trying to work out where this will physically go

---

## :memo:&nbsp; IP addresses

Can generally be viewed at [settings.yaml](./clusters/secrets/generic/settings.yaml)

---
## :handshake:&nbsp; Community

A lot of inspiration for my cluster came from the people that have shared their cluster configuration with me. Thanks to all the people who donate their time to the Home Operations community. Join us on [Discord](https://discord.gg/home-operations)!
