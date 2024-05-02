{{- /*
Kubernetes standard labels
*/}}
{{- define "common.labels.standard" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ include "common.names.chart" . }}
{{- end -}}

{{- /*
Labels used on immutable fields such as deploy.spec.selector.matchLabels or svc.spec.selector
*/}}
{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- /*
Harness labels
*/}}
{{- define "common.labels.harness" -}}
harness.io/release-name: {{ .Values.harness.releaseName }}
harness.io/track: {{ .Values.harness.track }}
{{- end -}}

{{- /*
Datadog labels
*/}}
{{- define "common.labels.datadog" -}}
tags.datadoghq.com/env: {{ .Values.datadog.environment }}
tags.datadoghq.com/service: {{ .Values.datadog.service }}
tags.datadoghq.com/version: {{ .Values.datadog.version | quote }}
admission.datadoghq.com/enabled: "true"
{{- end }}