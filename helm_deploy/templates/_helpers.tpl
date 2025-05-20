{{/*
Expand the name of the chart.
*/}}
{{- define "laa-assess-crime-forms.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "laa-assess-crime-forms.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "laa-assess-crime-forms.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "laa-assess-crime-forms.labels" -}}
helm.sh/chart: {{ include "laa-assess-crime-forms.chart" . }}
{{ include "laa-assess-crime-forms.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Default Security Context
*/}}
{{- define "laa-assess-crime-forms.defaultSecurityContext" -}}
runAsNonRoot: true
allowPrivilegeEscalation: false
seccompProfile:
  type: RuntimeDefault
capabilities:
  drop: [ "ALL" ]
{{- end }}

{{/*
Selector labels
*/}}
{{- define "laa-assess-crime-forms.selectorLabels" -}}
app.kubernetes.io/name: {{ include "laa-assess-crime-forms.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "laa-assess-crime-forms.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "laa-assess-crime-forms.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Function to return the name for a UAT redis chart master node host
This duplicates bitnami/redis chart's internal logic whereby
If branch name contains "redis" then the redis-release-name appends "-master", otherwise it appends "-redis-master"
*/}}
{{- define "laa-assess-crime-forms.redisUatHost" -}}
  {{- $redis_fullName := (include "common.names.fullname" .Subcharts.redis) -}}
  {{- printf "%s-master.%s.svc.cluster.local" $redis_fullName .Release.Namespace -}}
{{- end -}}

{{/*
Function to return the internal host name of the current service
*/}}
{{- define "laa-assess-crime-forms.internalHostName" -}}
  {{- printf "%s.%s.svc.cluster.local" .Values.nameOverride .Release.Namespace -}}
{{- end -}}

{{/*
Function to return a list of whitelisted IPs allowed to access the service.
*/}}
{{- define "laa-assess-crime-forms.whitelist" -}}
{{- if .Values.ingress.whitelist.enabled }}
    {{- .Values.pingdomIPs }},{{- .Values.sharedIPs }}
{{- end -}}
{{- end -}}
