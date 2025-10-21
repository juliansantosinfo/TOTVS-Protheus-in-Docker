-- Cria o banco de dados "protheus" com encoding LATIN1, se ainda não existir

-- Verifica se o banco já existe
SELECT
    'CREATE DATABASE DATABASE_NAME
     WITH OWNER = DATABASE_USERNAME
     ENCODING = ''LATIN1''
     LC_COLLATE = ''pt_BR.cp1252''
     LC_CTYPE = ''pt_BR.cp1252''
     CONNECTION LIMIT = -1
     TEMPLATE = template0;'
WHERE NOT EXISTS (
    SELECT FROM pg_database WHERE datname = 'DATABASE_NAME'
)\gexec
-- O comando \gexec é uma metacomando do psql, que executa o resultado da SELECT como SQL. 
-- Ele só funciona dentro do psql, não em PL/pgSQL.
