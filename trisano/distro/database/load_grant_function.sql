CREATE LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_grant(usr text, prv text, ptrn text, nsp text)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  obj record;
  num integer;
BEGIN
  num:=0;
  FOR obj IN SELECT relname FROM pg_class c
    JOIN pg_namespace ns ON (c.relnamespace = ns.oid) WHERE
    relkind in ('r','v','S') AND
      nspname = nsp AND
    relname LIKE ptrn
  LOOP
    EXECUTE 'GRANT ' || prv || ' ON ' || obj.relname || ' TO ' || usr;
    num := num + 1;
  END LOOP;
  RETURN num;
END;
$$;
