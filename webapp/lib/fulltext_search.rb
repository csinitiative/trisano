# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
module FulltextSearch

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def fulltext_join(options)
      unless options[:fulltext_terms].blank?
        <<-JOIN
          INNER JOIN (\n#{fulltext(options[:fulltext_terms])}\n) search_results
              ON (search_results.search_result_id = people.id AND
                  search_results.rank > 0.2)
        JOIN
      end
    end

    def fulltext_order(options)
      unless options[:fulltext_terms].blank?
        "rank DESC"
      end
    end

    # planner is better if fulltext is not in a function
    def fulltext(terms)
      terms = sanitize_sql_for_conditions(['?', terms])
      returning [] do |result|
        result << "SELECT"
        result << fulltext_select(terms).join(",")
        result << "FROM ("
        result << text_search_results_query(terms)
        result << ") b"
        result << "ORDER BY rank DESC"
      end.join("\n")
    end

    def fulltext_select(terms)
      returning [] do |fields|
        fields << "id AS search_result_id"
        fields << "#{rank_field_defn(terms)} AS rank"
      end
    end

    def rank_field_defn(terms)
      returning [] do |parts|
        parts << "summed_rank"
        parts << "similarity(COALESCE(last_name, ''), #{terms})"
        parts << "similarity(COALESCE(first_name, ''), #{terms})"
        parts << soundex_calc(terms)
      end.join(' + ')
    end

    def soundex_calc(terms)
      calcs = returning([]) do |calc|
        calc << "CASE WHEN soundex(#{terms}) = soundex(first_name) THEN 1 ELSE 0 END"
        calc << "CASE WHEN soundex(#{terms}) = soundex(last_name) THEN 1 ELSE 0 END"
        calc << "CASE WHEN metaphone(#{terms}, 10) = metaphone(first_name, 10) THEN 1 ELSE 0 END"
        calc << "CASE WHEN metaphone(#{terms}, 10) = metaphone(last_name, 10) THEN 1 ELSE 0 END"
      end.join(" + \n\t\t")
      "(\n\t\t#{calcs}\n\t) / 4"
    end

    def text_search_results_query(terms)
      returning [] do |parts|
        parts << "SELECT"
        parts << text_search_fields
        parts << "FROM ("
        parts << tsquery_sub_queries(terms)
        parts << ") a"
        parts << "GROUP BY id, first_name, last_name"
      end.join("\n")
    end

    def text_search_fields
      "id, last_name, first_name, SUM(rank) AS summed_rank"
    end

    def tsquery_sub_queries(terms)
      returning [] do |subs|
        subs << full_name_trgrm_query(terms)
        subs << first_name_trgrm_query(terms)
        subs << last_name_trgrm_query(terms)
        subs << full_name_simple_tsvector_query(terms)
      end.join("\nUNION\n")
    end

    def full_name_trgrm_query(terms)
      trgrm_query(terms, "get_full_name(first_name, last_name)")
    end

    def first_name_trgrm_query(terms)
      trgrm_query(terms, "first_name")
    end

    def last_name_trgrm_query(terms)
      trgrm_query(terms, "last_name")
    end

    def trgrm_query(terms, name)
      %Q[
         SELECT id, first_name, last_name,
            ts_rank(get_trigram_tsvector(#{name}),
                to_tsquery('simple_no_stop'::regconfig, array_to_string(show_trgm(lower(#{terms})), '|'::text))) AS rank
         FROM people
         WHERE
             get_trigram_tsvector(#{name}) @@
             to_tsquery('simple_no_stop'::regconfig, array_to_string(show_trgm(lower(#{terms})), '|'::text))
      ]
    end

    def full_name_simple_tsvector_query(terms)
      %Q[
         SELECT id, first_name, last_name,
             ts_rank(
                 to_tsvector('simple_no_stop'::regconfig, get_full_name(first_name, last_name)),
                 to_tsquery('simple_no_stop'::regconfig, array_to_string(regexp_split_to_array(#{terms}, E'\\\\s+'), '|'))
              )
         FROM people
             WHERE
             to_tsvector(get_full_name(first_name, last_name)) @@
             to_tsquery('simple_no_stop'::regconfig, array_to_string(regexp_split_to_array(#{terms}, E'\\\\s+'), '|'))
      ]
    end

  end
end
