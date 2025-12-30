# Clona um banco de dados de origem a partir dos metadados
# metadados.sql gerados com o extrair-metadados.ps1.
# Esse script espera a versão do firebird do banco de origem
# e de saída (3 ou 5), o sistema ao qual eles pertencem,
# e o nome associado a eles (o cliente).

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

# Lê as configurações do banco de saída
$config = Get-Content ".\firebird-v${version_out}\config.json" | ConvertFrom-Json

# Configura isql para apontar para o isql do firebird da versão de saída
# para poder restaurar os metadados usando essa versão
Set-Alias isql "$($config.firebird)\isql.exe"

# Guarda os diretórios do banco de entrada e de saída
$db_dir_in = ".\firebird-v${version_in}\${system}\bancos\${database}"
$db_dir_out = ".\firebird-v${version_out}\${system}\bancos\${database}"

# Concatena os caminhos dos metadados, do log e do banco de destino
$metadata_path = "${db_dir_in}\metadados.sql"
$log_path = "${db_dir_out}\clone.log"
$db_path = "${db_dir_out}\clone.fdb"

# Define o SQL que cria o banco de dados de destino
$script = "CREATE DATABASE '$db_path' PAGE_SIZE 16384 DEFAULT CHARACTER SET ISO8859_1;"

# Cria banco de dados utilizando o script definido
$script | isql -q

# Clona o BD de origem a partir dos metadados
isql -user SYSDBA -password masterkey "$db_path" -charset ISO8859_1 -i "$metadata_path" -o "$log_path" -m
