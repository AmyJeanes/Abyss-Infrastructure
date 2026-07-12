{{/*
Build NTFY_AUTH_USERS: "name:hash:role,..." from .Values.auth.users, pulling
each user's bcrypt hash from .Values.auth.passwordHashes (keyed by name).
*/}}
{{- define "ntfy.authUsers" -}}
{{- $hashes := .Values.auth.passwordHashes | default dict -}}
{{- $out := list -}}
{{- range .Values.auth.users -}}
{{- $hash := required (printf "auth.passwordHashes.%s is required" .name) (index $hashes .name) -}}
{{- $out = append $out (printf "%s:%s:%s" .name $hash (.role | default "user")) -}}
{{- end -}}
{{- join "," $out -}}
{{- end -}}

{{/*
Build NTFY_AUTH_ACCESS: "user:topic:permission,..." from each user's access list.
*/}}
{{- define "ntfy.authAccess" -}}
{{- $out := list -}}
{{- range .Values.auth.users -}}
{{- $user := .name -}}
{{- range (.access | default list) -}}
{{- $out = append $out (printf "%s:%s:%s" $user .topic .permission) -}}
{{- end -}}
{{- end -}}
{{- join "," $out -}}
{{- end -}}

{{/*
Build NTFY_AUTH_TOKENS: "user:token[:label],..." from .Values.auth.tokens.
*/}}
{{- define "ntfy.authTokens" -}}
{{- $out := list -}}
{{- range .Values.auth.tokens -}}
{{- $entry := printf "%s:%s" .user .token -}}
{{- with .label }}{{- $entry = printf "%s:%s" $entry . -}}{{- end -}}
{{- $out = append $out $entry -}}
{{- end -}}
{{- join "," $out -}}
{{- end -}}
