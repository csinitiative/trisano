module NameAndBirthdateSearch

  def find_by_name_and_bdate(options)
    options.symbolize_keys!
    options[:fulltext_terms] = options[:fulltext_terms].strip if options[:fulltext_terms]
    validate_bdate(options)
    unless options[:use_starts_with_search]
      options[:fulltext_terms] ||= "#{options.delete(:last_name)} #{options.delete(:first_name)}".strip
    end
    find_or_paginate_by_sql(create_name_and_bdate_sql(options), options)
  end

  def validate_bdate(bdate)
    bdate = bdate[:birth_date] if bdate.is_a?(Hash)
    return if bdate.blank?
    if bdate.is_a? String
      parsed = ParseDate.parsedate(bdate)
      raise(I18n.translate('invalid_birthdate')) unless parsed[0] and parsed[1] and parsed[2]
    end
  end

  def find_or_paginate_by_sql(select, options={})
    # This causes another very expensive COUNT query.  Generally, a query returning more than 500 is useless anyway,
    # so let's just cap it.

    #if options[:page_size] && options[:page]
    #  self.paginate_by_sql select, :page => options[:page], :per_page => options[:page_size]
    #else
    #  self.find_by_sql select
    #end
    self.find_by_sql select + " LIMIT 500"
  end

  def create_name_and_bdate_sql(options)
    returning [] do |sql|
      sql << select(name_and_bdate_select)
      sql << from(name_and_bdate_from(options))
      sql << name_and_bdate_joins(options).join("\n")
      sql << where(name_and_bdate_conditions(options))
      sql << order_by(name_and_bdate_order(options))
    end.compact.join("\n")
  end

  def name_and_bdate_select
    returning [] do |fields|
      fields << "people.entity_id"
      fields << "people.last_name"
      fields << "people.first_name"
      fields << "people.birth_date"
      fields << "external_codes.code_description AS birth_gender"
      fields << "events.id"
      fields << "events.id AS event_id"
      fields << "events.type AS event_type"
      fields << "events.event_onset_date"
      fields << "diseases.disease_name"
      fields << "diseases.id AS disease_id"
      fields << "jurisplace.short_name AS jurisdiction_short_name"
      fields << "jurispart.secondary_entity_id AS jurisdiction_entity_id"
      fields << "sec_juris.secondary_jurisdiction_entity_ids AS secondary_jurisdictions"
      fields << "events.deleted_at"
      fields << "people.middle_name"
    end
  end

  def name_and_bdate_from(options)
    if options[:fulltext_terms].blank?
      "people"
    else
      returning "" do |result|
        result << "(\n#{fulltext(options[:fulltext_terms])}\n) search_results\n"
        result << "INNER JOIN people ON search_result_id = people.id AND rank > 0.2"
      end
    end
  end

  def name_and_bdate_joins(options)
    returning [] do |joins|
      joins << "INNER JOIN entities pplentities ON pplentities.id = people.entity_id"
      joins << "LEFT JOIN external_codes ON external_codes.id = people.birth_gender_id"
      joins << "LEFT JOIN #{interested_party_subselect} interested_parties ON people.entity_id = interested_parties.primary_entity_id"
      joins << "LEFT JOIN events ON interested_parties.event_id = events.id"
      joins << "LEFT JOIN disease_events ON disease_events.event_id = events.id"
      joins << "LEFT JOIN diseases ON disease_events.disease_id = diseases.id"
      joins << "LEFT JOIN participations jurispart ON (events.id = jurispart.event_id AND jurispart.type = 'Jurisdiction')"
      joins << "LEFT JOIN places jurisplace ON (jurispart.secondary_entity_id = jurisplace.entity_id)"
      joins << secondary_jurisdictions_join
    end.compact
  end

  # This subselect returns id, primary_entity_id and event_id from all
  # InterestedParty participations that the current user can see (with
  # participations for sensitive events filtered out).
  def interested_party_subselect
    %Q{
      (SELECT DISTINCT ON (participations.id) participations.id, participations.primary_entity_id, participations.event_id FROM participations
        INNER JOIN events ON events.id = participations.event_id
        INNER JOIN participations jurispart ON (jurispart.type = 'Jurisdiction' AND jurispart.event_id = events.id)
        INNER JOIN places jurisplace ON (jurisplace.entity_id = jurispart.secondary_entity_id)
        #{secondary_jurisdictions_join}
        LEFT JOIN disease_events ON (disease_events.event_id = events.id)
        LEFT JOIN diseases ON (disease_events.disease_id = diseases.id)
        WHERE participations.type = 'InterestedParty' AND
          events.type IN ('MorbidityEvent','ContactEvent','AssessmentEvent') AND
          #{sensitive_disease_conditions}
      )
    }
  end

  def secondary_jurisdictions_join
    %Q[ LEFT JOIN (
          SELECT event_id,
            CASE
              WHEN secondary_jurisdiction_inner IS DISTINCT FROM ARRAY[NULL]::integer[]
                THEN secondary_jurisdiction_inner
              ELSE ARRAY[]::integer[]
            END AS secondary_jurisdiction_entity_ids
            FROM (
              SELECT
                events.id AS event_id,
                ARRAY_ACCUM(p.secondary_entity_id) AS secondary_jurisdiction_inner
              FROM
                events
                LEFT JOIN participations p
                  ON (
                    p.event_id = events.id AND p.type = 'AssociatedJurisdiction'
                  )
                GROUP BY
                  events.id
            ) sec_juris_inner
          ) sec_juris
        ON (sec_juris.event_id = events.id)
    ]
  end

  def name_and_bdate_conditions(options)
    returning [] do |conditions|
      conditions << "pplentities.deleted_at IS NULL"
      conditions << interested_party_filter_conditions
      conditions << name_conditions(options, :last_name, :first_name, :use_starts_with_search)
      conditions << bdate_conditions(options)
    end.compact
  end

  def bdate_conditions(options)
    return if options[:birth_date].blank?
    if options.any? {|k,v| k != :birth_date && !v.blank?}
      sql = "(birth_date = ? OR birth_date IS NULL)"
    else
      sql = "birth_date = ?"
    end
    sanitize_sql_for_conditions([sql, options[:birth_date]])
  end

  def sensitive_disease_conditions
    %Q[
      (
        diseases.sensitive IS NULL
        OR
        NOT diseases.sensitive
        OR
        secondary_jurisdiction_entity_ids || jurispart.secondary_entity_id &&
            ARRAY(
                SELECT
                    DISTINCT rm.jurisdiction_id
                FROM
                    privileges p
                    JOIN privileges_roles pr
                        ON (pr.privilege_id = p.id)
                    JOIN role_memberships rm
                        USING (role_id)
                    JOIN users u
                        ON (u.id = rm.user_id)
                WHERE
                    priv_name = 'access_sensitive_diseases' AND
                    u.id = #{User.current_user.id}
            )
    )
    ]
  end

  def interested_party_filter_conditions
    <<-SQL
      (
        interested_parties.id IS NOT NULL OR
        NOT EXISTS
        (
          SELECT id FROM participations
            WHERE type IN ('Clinician','Reporter')
            AND secondary_entity_id = people.entity_id
        )
      )
    SQL
  end

  def name_and_bdate_order(options)
    returning [] do |order|
      order << name_order(options)
      order << bdate_order(options)
      order << fulltext_order(options)
      order << "people.entity_id"
      order << "events.id DESC"
    end.flatten.compact
  end

  def name_order(options)
    returning [] do |order|
      unless options[:last_name].blank?
        order << 'last_name'
        order << 'first_name'
      else
        unless options[:first_name].blank?
          order << 'first_name'
          order << 'last_name'
        end
      end
    end.compact
  end

  def bdate_order(options)
    "birth_date" unless options[:birth_date].blank?
  end

  def having(conditions)
    unless conditions.empty?
      "HAVING #{conditions.join("\nAND\n")}"
    end
  end

  def where(conditions)
    unless conditions.empty?
      "WHERE #{conditions.join("\nAND\n")}"
    end
  end

  def from(table_or_sub_select)
    "FROM\n#{table_or_sub_select}"
  end

  def select(field_array)
    "SELECT\n#{field_array.join(",\n")}"
  end

  def order_by(order_fields)
    "ORDER BY #{order_fields.join(', ')}"
  end
end
