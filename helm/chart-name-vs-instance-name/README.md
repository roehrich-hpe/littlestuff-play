# Chart Name versus Instance Name

I have helm v3.12.0, and a KIND env.

```console
helm create rookery
```

## Helm Template

The template command has this usage:

```none
helm template [NAME] [CHART] [flags]
```

The CHART is a path to the chart, whether it's a local unpacked chart directory or a URL.

The NAME is the name that will be given to this instance of the chart.  This is also referred to as the **release name**.

If we specify only one of NAME or CHART, then it uses that value as the CHART, expecting it to be a local unpacked chart directory.  Then we get a NAME placeholder value of `release-name` prepended to resource names and used in the `app.kubernetes.io/instance` annotation.

```console
$ helm template rookery
apiVersion: v1
kind: ServiceAccount
metadata:
  name: release-name-rookery
  labels:
    helm.sh/chart: rookery-0.1.0
    app.kubernetes.io/name: rookery
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
[...]
```

If we specify both the NAME and CHART, then CHART is expected to be the name of the local unpacked chart directory.  In this case we can refer to that directory as `rookery` or as `./rookery`.  Notice the difference in the resource name and in the annotation, now that a NAME placeholder value is not being used.  Also, notice how using the same value for the NAME and CHART affects the resource names.

```console
$ helm template rookery ./rookery
apiVersion: v1
kind: ServiceAccount
metadata:
  name: rookery
  labels:
    helm.sh/chart: rookery-0.1.0
    app.kubernetes.io/name: rookery
    app.kubernetes.io/instance: rookery
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
[...]

# Not using dot-slash:
$ helm template rookery rookery
[same output as above]
```

Now we can give our instance of the chart a unique NAME.  Let's call it `red-bird`.  Notice how the NAME value is incorporated into the resource names and the annotation:

```console
$ helm template red-bird rookery
apiVersion: v1
kind: ServiceAccount
metadata:
  name: red-bird-rookery
  labels:
    helm.sh/chart: rookery-0.1.0
    app.kubernetes.io/name: rookery
    app.kubernetes.io/instance: red-bird
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
[...]
```

## Helm Install

Install a release, or instance, of the chart.  Let's call it `blue-bird`.

```console
$ helm install blue-bird rookery 
NAME: blue-bird
LAST DEPLOYED: Fri May 12 15:30:38 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
[...]
```

Check the pod:

```console
$ kubectl get pods   
NAME                                 READY   STATUS    RESTARTS   AGE
blue-bird-rookery-78b9754c87-xkqhl   1/1     Running   0          12s
```

Check the chart releases (or instances):

```console
$ helm list
NAME     	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART        	APP VERSION
blue-bird	default  	1       	2023-05-12 15:30:38.144164 -0500 CDT	deployed	rookery-0.1.0	1.16.0     
```

Uninstall the release (or instance):

```console
$ helm uninstall blue-bird
release "blue-bird" uninstalled
```
