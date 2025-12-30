# Migração do 3.0 para o 5.0

## Passo a passo

1. Remover UDFs
2. Reparar banco
3. Extrair metadados
4. Ajeitar metadados
5. Clonar com metadados
6. Backup e restore
7. Adicionar trigger global

## Estrutura

Abaixo está disponível a estrutura utilizada por esse projeto para organizar o processo de migração.

```txt
🔥 Firebird v3.0
└── 🖥️ <sistema>
    ├── 🗄️ bancos
    │   └── 📁 <banco>
    │       ├── 🧬 in.fdb           (banco de origem)
    │       ├── 🧾 metadados.sql    (ddl gerado do banco)
    │       ├── 📦 backup.fbk       (backup gerado do banco)
    │       └── 📄 backup.log       (log do backup)
    └── 🛠️ reparador.sql            (reparador de inconsistências dos bancos)
```

```txt
🔥 Firebird v5.0
└── 🖥️ <sistema>
    └── 🗄️ bancos
        └── 📁 <banco>
            ├── 🧪 teste.fdb        (banco de teste criado com os metadados do banco de origem)
            ├── 📄 teste.log        (log da criação do banco de teste)
            ├── 🧬 out.fdb          (banco de destino restaurado a partir de um backup)
            └── 📄 restore.log      (log da restauração do banco)
```

## Remoção de UDFs

Foi-se examinada a estrutura dos bancos do SCGWin na versão 3.0 e foi identificada a presença das seguintes UDFs, algumas das quais não há dependências e outras sim:

- DOW
- FLOOR
- LTRIM
- RTRIM
- SRIGHT
- STRLEN
- SUBSTR
- TRUNCATE

## Diagnóstico de problemas

Em uma pasta com os executáveis do **Firebird 3.0** (somente o `isql.exe` é realmente necessário nessa etapa), utilize esse comando para extrair a estrutura (metadados) do banco `3.0` para um script `sql` capaz de recriá-la.

```sh
.\isql <origem.fdb> -x -o <metadados.sql>
```

No arquivo `sql` criado, descomente a linha semelhante à seguir, corrigindo o caminho do banco de dados para apontar para aonde você quer que ele seja criado.

```sql
CREATE DATABASE <destino.fdb> PAGE_SIZE 16384 DEFAULT CHARACTER SET ISO8859_1;
```

Esse `sql` criado traz identificadores do banco com nome "LOCAL" sem propriamente envolvê-los em aspas, como é necessário na versão 5. Para corrigir isso, use o `refatorador.py`.

Em um diretório com os executáveis do **Firebird 5.0** (somente o `isql.exe` é realmente necessário nessa etapa), use o comando a seguir para recriar a estrutura do banco em um novo banco.

```sh
.\isql -i <metadados.sql> -o <erro.log> -m
```

Nessa etapa, provavelmente surgirão um monte de erros no arquivo de `log` especificado. Esse é o momento chato de verificá-los e corrigí-los manualmente. Para evitar isso nas outras migrações, um script genérico capaz de solucionar esses erros está sendo desenvolvido.

## Refatoração dos metadados

Quando o `isql` gera os metadados do banco, há duas imperfeições que impedem o teste bem sucedido da clonagem na versão 5.0:

- O uso de LOCAL sem aspas
- O uso de GRANT ON sem o tipo de permissão em ALT_CUSTOMATPRIMA e LOTE
