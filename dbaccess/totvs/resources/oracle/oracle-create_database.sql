-- Script para preparar o ambiente Oracle para o Protheus
-- Nota: O Protheus/DBAccess geralmente requer um schema/user pré-criado.

DECLARE
  user_count NUMBER;
BEGIN
  SELECT count(*) INTO user_count FROM all_users WHERE username = UPPER('DATABASE_USERNAME');
  IF user_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER DATABASE_USERNAME IDENTIFIED BY "DATABASE_PASSWORD"';
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, DBA TO DATABASE_USERNAME';
    EXECUTE IMMEDIATE 'ALTER USER DATABASE_USERNAME QUOTA UNLIMITED ON USERS';
    DBMS_OUTPUT.PUT_LINE('User DATABASE_USERNAME created.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('User DATABASE_USERNAME already exists.');
  END IF;
END;
/
exit;
