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
    if options[:page_size] && options[:page]
      self.paginate_by_sql select, :page => options[:page], :per_page => options[:page_size]
    else
      self.find_by_sql select
    end
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
      fields << "events.id AS id"
      fields << "events.id AS event_id"
      fields << "events.type AS event_type"
      fields << "events.event_onset_date"
      fields << "diseases.disease_name AS disease_name"
      fields << "jurisplace.short_name AS jurisdiction_short_name"
      fields << "jurispart.secondary_entity_id AS jurisdiction_entity_id"
      fields << "sec_juris.secondary_jurisdiction_entity_ids AS secondary_jurisdictions"
      fields << "events.deleted_at"
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
      joins << "INNER JOIN participations pplpart ON (pplpart.type = 'InterestedParty' AND pplpart.primary_entity_id = people.entity_id)"
      joins << "LEFT JOIN events ON (events.id = pplpart.event_id AND events.type in ('MorbidityEvent', 'ContactEvent'))"
      joins << "LEFT JOIN participations jurispart ON (jurispart.type = 'Jurisdiction' AND jurispart.event_id = pplpart.event_id)"
      joins << "LEFT JOIN places jurisplace ON (jurisplace.entity_id = jurispart.secondary_entity_id)"
      joins << "LEFT JOIN disease_events ON disease_events.event_id = events.id"
      joins << "LEFT JOIN diseases ON disease_events.disease_id = diseases.id"
      joins << secondary_jurisdictions_join
    end.compact
  end

  def secondary_jurisdictions_join
    %Q[ LEFT JOIN (
          SELECT
            events.id AS event_id,
            ARRAY_ACCUM(p.secondary_entity_id) AS secondary_jurisdiction_entity_ids
          FROM
            events
            LEFT JOIN participations p
                ON (p.event_id = events.id AND p.type = 'AssociatedJurisdiction')
          GROUP BY events.id
      ) sec_juris
          ON (sec_juris.event_id = events.id)
    ]
  end

  def name_and_bdate_conditions(options)
    returning [] do |conditions|
      conditions << "pplentities.deleted_at IS NULL"
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
