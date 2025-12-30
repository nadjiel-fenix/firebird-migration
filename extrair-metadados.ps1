# Gera os metadados metadados.sql a partir de um banco in.fdb
# Esse script espera a versão do firebird do banco (3 ou 5),
# o sistema ao qual ele pertence, e o nome associado a ele
# (o cliente).

param (
    [Parameter(Position = 0, Mandatory)]
    [ValidateSet(3, 5)]
    [int]$versao,

    [Parameter(Position = 1, Mandatory)]
    [string]$sistema,

    [Parameter(Position = 2, Mandatory)]
    [string]$banco
)

$config = Get-Content ".\firebird-v${versao}\config.json" | ConvertFrom-Json

Set-Alias isql "$($config.firebird)\isql.exe"

$db_dir = ".\firebird-v${versao}\${sistema}\bancos\${banco}"

$db_path = "${db_dir}\in.fdb"
$metadata_path = "${db_dir}\metadados.sql"

# Extrai os metadados do banco utilizando o charset padrão ISO8859_1
isql $db_path -charset ISO8859_1 -x -o $metadata_path
