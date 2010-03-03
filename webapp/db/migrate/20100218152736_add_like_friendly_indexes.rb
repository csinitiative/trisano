class AddLikeFriendlyIndexes < ActiveRecord::Migration
  def self.up
    transaction do
      execute 'create index people_first_tpo on people (first_name text_pattern_ops);'
      execute 'create index people_last_tpo on people (last_name text_pattern_ops);'
      execute 'create index participations_type on participations (type);'
      execute 'DROP FUNCTION IF EXISTS search_for_name(TEXT);'
    end
  end

  def self.down
    transaction do
      execute 'drop index people_first_tpo;'
      execute 'drop index people_last_tpo;'
      execute 'drop index participations_type;'
      execute <<-FUNCTION
CREATE OR REPLACE FUNCTION search_for_name(TEXT) RETURNS SETOF RECORD LANGUAGE SQL STABLE AS $$
    SELECT id, last_name, first_name, sources, summed_rank +
        similarity(COALESCE(last_name, ''), $1) + similarity(COALESCE(first_name, ''), $1) +
        (
            CASE WHEN soundex($1) = soundex(first_name) THEN 1 ELSE 0 END +
            CASE WHEN soundex($1) = soundex(last_name) THEN 1 ELSE 0 END +
            CASE WHEN metaphone($1, 10) = metaphone(first_name, 10) THEN 1 ELSE 0 END +
            CASE WHEN metaphone($1, 10) = metaphone(last_name, 10) THEN 1 ELSE 0 END
         ) / 4 AS rank
   FROM (

        SELECT id, last_name, first_name, SUM(rank) AS summed_rank, ARRAY_ACCUM(source) AS sources FROM (
            SELECT id, first_name, last_name, rank, 'trigram_fts'::text AS source
            FROM search_for_trigram_fts($1) AS a(id iNTEGER, first_name VARCHAR, last_name VARCHAR, rank REAL)
                UNION
            SELECT id, first_name, last_name, rank, 'name_fts'::text AS source
            FROM search_for_name_fts($1) AS a(id INTEGER, first_name VARCHAR, last_name VARCHAR, rank REAL)
                UNION
            SELECT id, first_name, last_name, rank, 'name_trgm'::text AS source
            FROM search_for_name_trgm($1) AS a(id INTEGER, first_name VARCHAR, last_name VARCHAR, rank REAL)
        ) a
        GROUP BY id, first_name, last_name
    ) b
    ORDER BY rank DESC
$$;
FUNCTION
    end
  end
end
