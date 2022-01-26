# Install k3s

## provision/vars/

### inventory.yaml
- Update inventory to reflect your target hosts
  - mind the `ansible_user` variable
- Make sure your ssh keys are installed to the target machines in [inventory.yaml](https://github.com/crutonjohn/gitops/blob/main/provision/vars/inventory.yaml)

### kube-vip.yaml
- update the VIP for the control plane
- align interface name to be that of the control plane nodes

### others
- review the files for any applicable edits

## Permit direnv to load env
```
direnv allow .envrc
```

## Activate the pipenv

This will install the required pip packages and create a virtual python environment.

```
pipenv shell
```

## Overlaying the required repos

```
gilt overlay
```

- `gilt` will copy the required files from the [k8s-at-home cluster template](https://github.com/k8s-at-home/template-cluster-k3s) and use `ansible-galaxy` to install the required ansible roles.
- this will essentially create a rough-in "mirror" of the cluster template repo with some of our own mixins/customizations.

## Bootstrapping the k3s cluster

```
ansible-playbook -i provision/ansible/inventory/inventory.yaml provision/ansible/playbooks/k3s-install.yaml
```

- The playbook will run and dump a `kubeconfig` in `provision/kubeconfig`, which will automatically be sourced by our `direnv`.

Now your cluster should be running.

## Verify cluster status

```
kubectl get nodes -o wide
```
