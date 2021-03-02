{{- define "snapshot.labels" -}}
  - {{ .Values.labelDomain }}/app: {{ .Release.Name }}
  - app.kubernetes.io/instance: {{ .Release.Name }}
  - app.kubernetes.io/managed-by: {{ .Release.Service }}
  - app.kubernetes.io/name: {{ .Release.Name }}
  - helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}