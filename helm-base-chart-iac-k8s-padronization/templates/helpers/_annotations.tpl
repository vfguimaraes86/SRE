{{- /*
Kubernetes standard annotations
*/}}
{{- define "common.annotations.standard" -}}
dock.tech/business_unit: "{{ .Values.tags.business_unit }}"
dock.tech/customer: "{{ .Values.tags.customer }}"
dock.tech/application: "{{ .Values.tags.application }}"
dock.tech/env: "{{ .Values.tags.env }}"
dock.tech/owner: "{{ .Values.tags.owner }}"
dock.tech/pci_scope: "{{ .Values.tags.pci_scope }}"
{{- end -}}

{{- /*
Define AWS secret manager annotations
*/}}
{{- define "common.annotations.aws.secretManager" -}}
eks.amazonaws.com/role-arn: "{{ .Values.aws.secretManager.jwt.roleArn }}"
{{- end }}

{{- /*
Define Azure Keyvault annotations
*/}}
{{- define "common.annotations.azure.keyVault" -}}
azure.workload.identity/client-id: "{{ .Values.azure.keyVault.clientId }}"
azure.workload.identity/tenant-id: "{{ .Values.azure.keyVault.tenantId }}"
{{- end }}

{{- /*
Define Azure CSI annotations
*/}}
{{- define "common.annotations.azure.csi" -}}
pv.kubernetes.io/provisioned-by: "file.csi.azure.com"
{{- end }}