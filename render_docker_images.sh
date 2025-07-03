# Render Dockerfiles
gomplate -V -c .=releases.yaml -f templates/Dockerfile.tpl

# Render compose files
gomplate -V -c .=releases.yaml -f templates/compose.yaml.tpl
