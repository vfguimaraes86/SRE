{{- /*
Define Azure registry credentials
*/}}
{{- define "common.secrets.azure.registrySecrets" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .server (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}