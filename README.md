# Migração do 3.0 para o 5.0

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
