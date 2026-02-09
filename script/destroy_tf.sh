#!/bin/env bash




terraform destroy -target=helm_release.retail_store
terraform destroy -target=kubernetes_namespace.retail



terraform destroy --auto-approve