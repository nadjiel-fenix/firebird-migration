

param (
    [Parameter(Position = 0, Mandatory)]
    [Alias('versao')]
    [ValidateSet(3, 5)]
    [int]$version,

    [Parameter(Position = 1, Mandatory)]
    [Alias('sistema')]
    [string]$system,

    [Parameter(Position = 2, Mandatory)]
    [Alias('banco')]
    [string]$database
)

# Lê as configurações do banco
$config = Get-Content ".\firebird-v${version}\config.json" | ConvertFrom-Json

# Configura gbak para apontar para o gbak do firebird da versão
# para poder gerar o backup usando essa versão
Set-Alias gbak "$($config.firebird)\gbak.exe"

# Guarda o diretório do banco
$db_dir = ".\firebird-v${version}\${system}\bancos\${database}"

# Concatena os caminhos do banco original, dos logs e do backup
$db_path = "${db_dir}\in.fdb"
$backup_path = "${db_dir}\backup.fbk"
$log_path = "${db_dir}\backup.log"

gbak -b -v -g -y $log_path `
  $db_path $backup_path `
  -user SYSDBA `
  -password masterkey
