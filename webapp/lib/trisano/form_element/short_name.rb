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
module Trisano
  module FormElement
    module ShortName

      # return all the questions for self, w/ collisions marked
      def compare_short_names(other_tree, replacements=nil)
        replacements ||= {}
        results = []
        in_rolled_back_transaction do
          unless replacements.empty?
            Question.update(replacements.keys, replacements.values)
          end
          sql_options = {
            :other_tree_id => other_tree.tree_id,
            :this_tree_id => tree_id,
            :this_id => self.id,
            :this_lft => self.lft,
            :this_rgt => self.rgt
          }
          results << Question.find_by_sql([<<-SQL, sql_options])
          SELECT a.id, a.short_name, a.question_text, fi.collision, b.lft
            FROM questions a
            JOIN form_elements b ON a.form_element_id = b.id
            LEFT JOIN (SELECT true as collision, i.short_name, i.id
                         FROM questions i
                         JOIN form_elements f ON i.form_element_id = f.id
                        WHERE f.tree_id = :other_tree_id) as fi
                   ON fi.short_name = a.short_name
           WHERE b.tree_id = :this_tree_id
             AND (b.id = :this_id OR b.lft BETWEEN :this_lft AND :this_rgt)
          UNION
          SELECT c.id, c.short_name, c.question_text, jg.collision, d.lft
            FROM questions c
            JOIN form_elements d ON c.form_element_id = d.id
            LEFT JOIN (SELECT true as collision, j.short_name, j.id
                         FROM questions j
                         JOIN form_elements g ON j.form_element_id = g.id
                        WHERE g.tree_id = :this_tree_id
                          AND (g.id = :this_id OR g.lft BETWEEN :this_lft AND :this_rgt)) as jg
                   ON c.short_name = jg.short_name AND c.id > jg.id
           WHERE d.tree_id = :this_tree_id
             AND (d.id = :this_id OR d.lft BETWEEN :this_lft AND :this_rgt)
          ORDER BY lft, collision
        SQL
        end
        results.flatten.uniq
      end

    end
  end
end
