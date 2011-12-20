class UniqueLiveFormTemplate < ActiveRecord::Migration
  def self.up
    execute %{
        UPDATE forms
            SET status = 'Inactive'
        FROM (
            SELECT DISTINCT ON (template_id) template_id, id
            FROM forms
            WHERE
                status = 'Live' AND
                template_id IN (
                    SELECT template_id
                    FROM (
                        SELECT template_id, count(*)
                        FROM forms
                        WHERE status = 'Live'
                        GROUP BY template_id
                        HAVING count(*) > 1
                    ) foo
                )
            ORDER BY template_id, version DESC
        ) bar
        WHERE
            bar.template_id = forms.template_id AND 
            bar.id != forms.id AND
            forms.status = 'Live'
        RETURNING forms.id;
    }
    execute "CREATE UNIQUE INDEX unique_live_form_template ON forms (template_id) WHERE status = 'Live'"
  end

  def self.down
    execute 'DROP INDEX unique_live_form_template'
  end
end
