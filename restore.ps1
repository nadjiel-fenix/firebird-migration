
param (
    [Parameter(Position = 0, Mandatory)]
    [Alias('versao_inicial')]
    [ValidateSet(3, 5)]
    [int]$version_in,
    
    [Parameter(Position = 1, Mandatory)]
    [Alias('versao_final')]
    [ValidateSet(3, 5)]
    [int]$version_out,

    [Parameter(Position = 2, Mandatory)]
    [Alias('sistema')]
    [string]$system,

    [Parameter(Position = 3, Mandatory)]
    [Alias('banco')]
    [string]$database
)

# Lê as configurações do banco
$config = Get-Content ".\firebird-v${version_out}\config.json" | ConvertFrom-Json

# Configura gbak para apontar para o gbak do firebird da versão
# de destino da restauração
Set-Alias gbak "$($config.firebird)\gbak.exe"

# Guarda os diretórios de entrada e saída do banco
$db_dir_in = ".\firebird-v${version_in}\${system}\bancos\${database}"
$db_dir_out = ".\firebird-v${version_out}\${system}\bancos\${database}"

# Concatena os caminhos do banco final, dos logs e do backup
$backup_path = "${db_dir_in}\backup.fbk"
$db_path = "${db_dir_out}\out.fdb"
$log_path = "${db_dir_out}\restore.log"

# Executa a restauração, armazenando os logs de acordo
gbak -c -v -y $log_path `
  $backup_path `
  $db_path `
  -user SYSDBA `
  -pass masterkey
