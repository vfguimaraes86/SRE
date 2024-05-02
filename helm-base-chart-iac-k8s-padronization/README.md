# helm-base-chart-iac

Base Helm chart for general use

#### Comando para gerar o template localmente: 
`helm template <release name> -n <namespace> -f <arquivo de values adicional> <caminho do helm>`

#### Ex:
`helm template dock-app -n dock -f values-config.yaml .`