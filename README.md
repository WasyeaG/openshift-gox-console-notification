# OpenShift GOX Console Notification

This repository contains a clean-room Helm chart for deploying an OpenShift
ConsoleNotification.

The chart is deployed manually using standard Helm commands and has no
dependency on Argo CD or ApplicationSet.

## Repository structure

    charts/
    └── console-notification/
        ├── Chart.yaml
        ├── values.yaml
        ├── values-sbx.yaml
        └── templates/
            ├── _helpers.tpl
            └── console-notification.yaml

## Prerequisites

- Access to the target OpenShift cluster
- OpenShift CLI
- Helm 3
- Permission to manage cluster-scoped ConsoleNotification resources

## Verify the target cluster

    oc whoami
    oc config current-context
    oc get infrastructure cluster -o jsonpath='{.status.apiServerURL}{"\n"}'

Confirm that the current context points to gox-sbx.

## Validate the chart

Run Helm lint:

    helm lint charts/console-notification

Render the sandbox configuration:

    helm template gox-sbx-console-notification \
      charts/console-notification \
      -f charts/console-notification/values-sbx.yaml

## Manual deployment

Install or upgrade the chart:

    helm upgrade --install gox-sbx-console-notification \
      charts/console-notification \
      --namespace gox-console-notification \
      --create-namespace \
      -f charts/console-notification/values-sbx.yaml

## Verify the deployment

Check the Helm release:

    helm list -n gox-console-notification

    helm status gox-sbx-console-notification \
      -n gox-console-notification

Check the OpenShift resource:

    oc get consolenotification gox-sbx-console-notification

    oc describe consolenotification gox-sbx-console-notification

Open the gox-sbx OpenShift web console and confirm that the notification
appears at the top of the console.

## Update the notification

Modify:

    charts/console-notification/values-sbx.yaml

Then run:

    helm upgrade gox-sbx-console-notification \
      charts/console-notification \
      --namespace gox-console-notification \
      -f charts/console-notification/values-sbx.yaml

## Remove the notification

    helm uninstall gox-sbx-console-notification \
      --namespace gox-console-notification

## Design decisions

- The chart contains only the OpenShift ConsoleNotification resource.
- Notification text, location, colors, and environment are configurable.
- Sandbox-specific values are stored in values-sbx.yaml.
- Deployment is performed manually with Helm.
- No Argo CD Application or ApplicationSet resources are included.
- The implementation was created from the task requirements under the clean-room constraint.
