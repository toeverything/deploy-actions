// Generic env_vars template
[[ define "env_vars" -]]
  [[- range $idx, $var := . ]]
  [[ $var.key ]] = [[ $var.value | quote ]]
  [[- end ]]
[[- end ]]

// Generic mount template
[[ define "mounts" -]]
[[- range $idx, $mount := . ]]
        mount {
          type = [[ $mount.type | quote ]]
          target = [[ $mount.target | quote ]]
          source = [[ $mount.source | quote ]]
          readonly = [[ $mount.readonly ]]
          [[- if gt (len $mount.bind_options) 0 ]]
          bind_options {
            [[- range $idx, $opt := $mount.bind_options ]]
            [[ $opt.name ]] = [[ $opt.value | quote ]]
            [[- end ]]
          }
          [[- end ]]
        }
[[- end ]]
[[- end ]]

// Generic resources template
[[ define "resources" -]]
[[- $resources := . ]]
      resources {
        cpu    = [[ $resources.cpu ]]
        memory = [[ $resources.memory ]]
      }
[[- end ]]

[[ define "network" -]]
network {
  [[- range $idx, $service := . ]]
  [[- range $idx, $port := .ports ]]
      port "affine-[[ $service.name ]]-[[ $port.name ]]" {
        to           = [[ $port.to ]]
        host_network = "tailscale"
      }
  [[- end ]]
  [[- end ]]
    }
[[- end -]]


[[ define "services" -]]
service {
  [[- range $idx, $service := . ]]
  [[- range $idx, $port := .ports ]]
      tags = [[- if not $port.domain -]]["urlprefix-[[ $service.name ]].affine.live/"][[- else -]]["urlprefix-[[ $port.domain ]]/"][[- end ]]
      port = "affine-[[ $service.name ]]-[[ $port.name ]]"
      check {
        name     = "AFFiNE [[ $service.name ]] Check"
        type     = [[- if not $service.check_type -]]"http"[[- else -]][[ $service.check_type | quote ]][[- end ]]
        path     = [[- if not $service.check_path -]]"/"[[- else -]][[ $service.check_path | quote ]][[- end ]]
        interval = [[- if not $service.check_interval -]]"10s"[[- else -]][[ $service.check_interval | quote ]][[- end ]]
        timeout  = [[- if not $service.check_timeout -]]"2s"[[- else -]][[ $service.check_timeout | quote ]][[- end ]]
      }
  
  [[- end ]]
  [[- end ]]
    }
[[- end -]]

// Generic "service" block template
[[ define "groups" -]]
  [[- if . ]]
    [[ template "network" . ]]
    [[ template "services" . ]]
    [[- range $idx, $service := . ]]
    task "affine-[[ $service.name ]]" {
      driver = "docker"

      config {
        image      = "[[ $service.image ]]:[[ $service.tag ]]"
        force_pull = true
        ports      = [
          [[- range $idx, $port := .ports ]]
          "affine-[[ $service.name ]]-[[ $port.name ]]",
          [[- end ]]
        ]
      }
      [[- if $service.envs ]]
      env {
        [[- range $idx, $var := $service.envs ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]
      resources {
        cpu    = [[- if not $service.cpu -]]100[[- else -]][[ $service.cpu ]][[- end ]] # MHz
        memory = [[- if not $service.memory -]]64[[- else -]][[ $service.memory ]][[- end ]] # MB
      }
    }
    [[- end ]]
  [[- end ]]
[[- end -]]

// only deploys to a region if specified
[[ define "region" -]]
[[- if not (eq .region "") -]]
  region      = [[ .region | quote]]
[[- end -]]
[[- end -]]

// Generic "jobs" block template
[[ define "jobs" -]]
job "affine-[[ .name ]]" {
  [[ template "region" . ]]
  datacenters = [[ .datacenters | toJson ]]
  type        = "service"
  namespace   = [[ .namespace | quote ]]
      
  update {
    stagger      = "30s"
    max_parallel = 2
  }
      
  group "[[ .name ]]" {
    count = 1
    [[ template "groups" .services ]]
  }
}
[[- end -]]