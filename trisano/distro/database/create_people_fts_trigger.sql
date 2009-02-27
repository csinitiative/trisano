--LANGUAGE plpgsql
--AS $$

CREATE FUNCTION people_trigger() RETURNS trigger
    AS $$
                      begin
                        new.vector :=
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.first_name,'')), 'B') ||
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.last_name,'')), 'B') ||
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.first_name_soundex,'')), 'A') ||
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.last_name_soundex,'')), 'A');
                        return new;
                      end
                    $$
    LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate
    BEFORE INSERT OR UPDATE ON people
    FOR EACH ROW
    EXECUTE PROCEDURE people_trigger();
