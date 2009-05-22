CREATE FUNCTION build_form_tables() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    form_name             TEXT;
    question_name         TEXT;
    questions_per_table   INTEGER := 200;
    i                     INTEGER;
    table_count           INTEGER;
    cols_plus_vals_clause TEXT := '';
    colnames_clause       TEXT := '';
    insert_col_clause     TEXT := '';
    answer_rec            RECORD;
    last_event            INTEGER;
    values_clause         TEXT;
    tmp                   TEXT;
    table_name            TEXT;
BEGIN
    FOR form_name IN SELECT DISTINCT short_name FROM forms WHERE short_name IS NOT NULL AND short_name != '' AND status = 'Published' LOOP
        -- For each form, find all the question short names that appear on it
        i := 0;
        colnames_clause := '';
        cols_plus_vals_clause := '';
        table_count := 1;
        FOR question_name IN SELECT DISTINCT q.short_name
                    FROM questions q JOIN form_elements fe ON fe.id = q.form_element_id
                    JOIN forms f ON f.id = fe.form_id JOIN answers a ON a.question_id = q.id
                    WHERE f.short_name = form_name
                    AND q.short_name IS NOT NULL
                    AND q.short_name != ''
                    LOOP
            -- Get some number of question short names
            IF colnames_clause != '' THEN
                colnames_clause := colnames_clause || ', ';
                cols_plus_vals_clause := cols_plus_vals_clause || ', ';
            END IF;
            colnames_clause := colnames_clause || quote_literal(question_name);
            cols_plus_vals_clause := cols_plus_vals_clause || quote_ident(question_name) || ' TEXT';
            i := i + 1;

            IF i > questions_per_table THEN
                PERFORM create_single_form_table(form_name, table_count, colnames_clause, cols_plus_vals_clause);
                table_count := table_count + 1;
                colnames_clause := '';
                cols_plus_vals_clause := '';
            END IF;
        END LOOP;
        IF colnames_clause != '' THEN
            PERFORM create_single_form_table(form_name, table_count, colnames_clause, cols_plus_vals_clause);
        END IF;
    END LOOP;
END;
$$;


CREATE FUNCTION create_single_form_table(form_name text, table_count integer, colnames_clause text, cols_plus_vals_clause text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    insert_col_clause TEXT;
    values_clause     TEXT;
    last_event        INTEGER;
    tmp               TEXT;
    answer_rec        RECORD;
    table_name        TEXT;
BEGIN
    table_name := quote_ident('formtable_' || lower(form_name) || '_' || table_count);
    insert_col_clause := '';
    values_clause := '';
    last_event := NULL;
    EXECUTE 'DROP TABLE IF EXISTS ' || table_name;
    RAISE NOTICE 'Creating table %', table_name;
    EXECUTE 'CREATE TABLE ' || table_name || ' (event_id INTEGER, ' || cols_plus_vals_clause || ')';
    tmp := 'SELECT a.event_id, q.short_name, a.text_answer
            FROM answers a JOIN questions q ON (q.id = a.question_id)
            JOIN form_elements fe ON (fe.id = q.form_element_id)
            JOIN forms f ON (fe.form_id = f.id)
            WHERE f.short_name = ' || quote_literal(form_name) || '
            AND q.short_name IN (' || colnames_clause || ')
            ORDER BY event_id';
    RAISE NOTICE 'To insert stuff, running %', tmp;
    FOR answer_rec IN EXECUTE tmp LOOP
        IF last_event IS NOT NULL AND last_event != answer_rec.event_id THEN
            tmp := 'INSERT INTO ' || table_name || ' (' || insert_col_clause || ') VALUES (' || values_clause || ')';
            RAISE NOTICE 'Running %', tmp;
            EXECUTE tmp;
            last_event := answer_rec.event_id;
            insert_col_clause := '';
            values_clause := '';
        END IF;

        IF insert_col_clause != '' THEN
            insert_col_clause := insert_col_clause || ', ';
            values_clause := values_clause || ', ';
        END IF;
        insert_col_clause := insert_col_clause || quote_ident(answer_rec.short_name);
        values_clause := values_clause || quote_literal(answer_rec.text_answer);
    END LOOP;
    IF last_event IS NOT NULL THEN
        tmp := 'INSERT INTO ' || table_name || ' (' || insert_col_clause || ') VALUES (' || values_clause || ')';
        RAISE NOTICE 'Running %', tmp;
        EXECUTE tmp;
    END IF;
END;
$$;
