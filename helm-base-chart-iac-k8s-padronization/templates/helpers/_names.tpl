{{- /*
Chart name
Truncated in 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "common.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Chart name and version
Truncated in 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Create a default fully qualified app name.
Truncated in 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.names.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /*
Define Azure registry name
*/}}
{{- define "common.names.azure.registry" -}}
{{- if and (.Values.azure.registry.registryNameOverride) (not .Values.azure.registry.enabled) -}}
{{- .Values.azure.registry.registryNameOverride }}
{{- else -}}
{{- printf "%s-registrycredentials" .Values.azure.registry.name -}}
{{- end }}
{{- end }}

{{- /*
Define Azure StorageAccount name
*/}}
{{- define "common.names.azure.storageAccountCredentials" -}}
{{- printf "%s-storageaccountcredentials" (include "common.names.fullname" .) -}}
{{- end }}

{{- /*
Define Azure pv & pvc name
*/}}
{{- define "common.names.azure.persistentVolume" -}}
{{- if and (.Values.azure.csi.persistentVolumeClaim.claimOverride) (not .Values.azure.csi.persistentVolumeClaim.enabled) (not .Values.azure.csi.persistentVolume.enabled) -}}
{{- .Values.azure.csi.persistentVolumeClaim.claimOverride }}
{{- else -}}
{{- printf "%s-storageaccount" .Release.Namespace -}}
{{- end }}
{{- end }}

{{- /*
Define Azure StorageClass name 
*/}}
{{- define "common.names.azure.storageClass" -}}
{{- if and (.Values.azure.csi.storageClass.storageClassnameOverride) (not .Values.azure.csi.storageClass.enabled) -}}
{{- .Values.azure.csi.storageClass.storageClassnameOverride }}
{{- else -}}
{{- printf "%s-storageaccount" .Release.Namespace  -}}
{{- end }}
{{- end }}

{{- /*
Define Azure KeyVault name
*/}}
{{- define "common.names.azure.keyVault" -}}
{{- printf "%s-keyvault" (include "common.names.fullname" .) -}}
{{- end }}

{{- /*
Define Azure KeyVault credentials name
*/}}
{{- define "common.names.azure.keyVaultCredentials" -}}
{{- printf "%s-keyvaultcredentials" (include "common.names.fullname" .) -}}
{{- end }}

{{- /*
Define AWS SecretManager name
*/}}
{{- define "common.names.aws.secretManager" -}}
{{- printf "aws-%s-secretmanager" (include "common.names.fullname" .) -}}
{{- end }}

{{- /*
Define AWS SecretManager credentials name
*/}}
{{- define "common.names.aws.secretManagerCredentials" -}}
{{- printf "aws-%s-secretmanagercredentials" (include "common.names.fullname" .) -}}
{{- end }}

{{- /*
Define istio gateway name
*/}}
{{- define "common.names.istio.gateway" -}}
{{- if and (.Values.istio.gateway.gatewayNameOverride) (not .Values.istio.gateway.enabled) -}}
{{- .Values.istio.gateway.gatewayNameOverride }}
{{- else -}}
{{- printf "istio-%s-gateway" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end }}

{{- /*
Define script configmap name
*/}}
{{- define "common.names.script" -}}
{{- printf "script-%s" (include "common.names.fullname" .) -}}
{{- end }}

{{- /*
Define ingress secret name
*/}}
{{- define "common.names.ingress.certificateCredentials" -}}
{{- printf "ingres-%s-certificate" .Values.ingress.tls.secretName -}}
{{- end }}