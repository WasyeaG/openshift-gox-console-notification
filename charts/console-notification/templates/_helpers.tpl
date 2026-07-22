{{/*
Return the deployment environment.
*/}}
{{- define "console-notification.environment" -}}
{{- required "environment must be set" .Values.environment -}}
{{- end }}
