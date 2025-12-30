# Executa o script de reparação de banco de dados,
# que corrige os erros identificados previamente nos bancos,
# como ambiguidade ou uso errado de SUSPEND.

param (
    [Parameter(Position = 0, Mandatory)]
    [Alias('sistema')]
    [string]$system,

    [Parameter(Position = 1, Mandatory)]
    [Alias('banco')]
    [string]$database
)

# Lê as configurações do banco
$config = Get-Content ".\config.json" | ConvertFrom-Json

# Configura isql para apontar para o isql do firebird da versão atual
Set-Alias isql "$($config.firebird)\isql.exe"

# Guarda o diretório do sistema e do banco
$system_dir = ".\${system}"
$db_dir = "${system_dir}\bancos\${database}"

# Concatena os caminhos do script de reparação, do banco e do arquivo de log
$repair_script = "${system_dir}\reparador.sql"
$db_path = "${db_dir}\in.fdb"
$log_path = "${db_dir}\reparo.log"

# Executa a reparação no banco de dados e armazena os logs
isql -user SYSDBA -password masterkey "$db_path" -charset ISO8859_1 -i "$repair_script" -o "$log_path" -m
