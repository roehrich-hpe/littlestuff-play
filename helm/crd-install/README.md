# CRD Installation

## Get a CRD to use

```console
$ git clone git@github.com:NearNodeFlash/lustre-fs-operator.git
$ cd lustre-fs-operator
$ make kustomize
$ bin/kustomize build config/crd > crd.yaml
$ cd ..
```

## Create a Chart

This is using helm version 3.12.0 with a KIND environment.

```console
helm create fsoper
```

## Setup the CRD

Setup the `crd` directory for helm 3 as described in the helm doc at [Custom Resource Definitions](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/).

Add the CRD to the chart, and fetch a test resource for that CRD.  Remove the namespace from that resource so it just goes to `default`.

```console
$ mkdir fsoper/crds
$ cp ~/lustre-fs-operator/crd.yaml fsoper/crds
$ cp ~/lustre-fs-operator/config/samples/lus_v1beta1_lustrefilesystem.yaml fsoper/templates/tests
$ sed -i.bak -e 's/.*namespace:.*//' fsoper/templates/tests/lus_v1beta1_lustrefilesystem.yaml
$ rm fsoper/templates/tests/lus_v1beta1_lustrefilesystem.yaml.bak
```

Use `helm template` to verify the chart and that it has the CRD and the test resource for it:

```console
helm template --include-crds fsoper
```

Or, a quick check:

```console
$ helm template fsoper | grep -E -e '^kind: CustomResourceDefinition' -e '^kind: LustreFileSystem'
kind: CustomResourceDefinition
kind: LustreFileSystem
```

## Install the Chart

Install an instance of the chart:

```console
$ helm install try1 fsoper
NAME: try1
LAST DEPLOYED: Tue May 16 16:32:11 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
[...]
```

Check that our CRD was installed:

```console
$ kubectl get crds
NAME                                 CREATED AT
lustrefilesystems.lus.cray.hpe.com   2023-05-16T21:32:09Z
```

Check that our test resource was applied:

```console
$ kubectl get lustrefilesystems
NAME    FSNAME   MGSNIDS         AGE
kauai   kauai    172.0.0.0@tcp   67s
```
