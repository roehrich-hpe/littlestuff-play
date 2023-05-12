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
$ mkdir fsoper/templates/crds
$ cp ~/lustre-fs-operator/crd.yaml fsoper/templates/crds
$ cp ~/lustre-fs-operator/config/samples/lus_v1beta1_lustrefilesystem.yaml fsoper/templates/tests
$ sed -i.bak -e 's/.*namespace:.*//' fsoper/templates/tests/lus_v1beta1_lustrefilesystem.yaml
$ rm fsoper/templates/tests/lus_v1beta1_lustrefilesystem.yaml.bak
```

Use `helm template` to verify the chart and that it has the CRD and the test resource for it:

```console
helm template fsoper
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
Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest: resource mapping not found for name: "kauai" namespace: "" from "": no matches for kind "LustreFileSystem" in version "lus.cray.hpe.com/v1beta1"
ensure CRDs are installed first
```

Ugh

Okay, break it down:

```console
$ kubectl apply -f fsoper/templates/crds/crd.yaml 
customresourcedefinition.apiextensions.k8s.io/lustrefilesystems.lus.cray.hpe.com created

$ kubectl get crds
NAME                                 CREATED AT
lustrefilesystems.lus.cray.hpe.com   2023-05-12T21:30:58Z
```

Then install, but skip the CRD:

```console
$ helm install --skip-crds try1 fsoper
Error: INSTALLATION FAILED: rendered manifests contain a resource that already exists. Unable to continue with install: CustomResourceDefinition "lustrefilesystems.lus.cray.hpe.com" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "try1"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "default"
```

Ugh, okay it didn't honor the `--skip-crds`.  Let's move that out and try again:

```console
$ mv fsoper/templates/crds fsoper
$ helm install try1 fsoper 
NAME: try1
LAST DEPLOYED: Fri May 12 16:34:54 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
[...]
```

Check that our test resource was applied:

```console
$ kubectl get lustrefilesystems
NAME    FSNAME   MGSNIDS         AGE
kauai   kauai    172.0.0.0@tcp   67s
```

