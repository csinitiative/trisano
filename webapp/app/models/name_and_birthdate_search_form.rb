class NameAndBirthdateSearchForm
  include ActiveRecord::Validations

  def self.human_name(options={})
    default = self.name.humanize
    I18n.t(self.name.underscore, { :scope => [:activerecord, :models], :default => default }.merge(options))
  end

  def self.human_attribute_name(attr)
    default = attr.humanize
    I18n.t(attr, :scope => [:activerecord, :attributes, self.name.underscore])
  end

  def self.self_and_descendants_from_active_record
    [self]
  end

  def initialize(params)
    @params = params.symbolize_keys
  end

  def birth_date
    @params[:birth_date]
  end

  def last_name
    @params[:last_name]
  end

  def first_name
    @params[:first_name]
  end

  def page_size
    @params[:page_size] ||= 50
  end

  def page
    @params[:page].blank? ? 1 : @params[:page]
  end

  def uses_starts_with_search?
    (not @params[:use_starts_with_search].blank?)
  end

  def valid?
    validate
    errors.empty?
  end

  def has_search_criteria?
    [:last_name, :first_name, :birth_date].any? do |sym|
      (not send(sym).blank?)
    end
  end

  def validate
    errors.clear
    parse_birth_date if birth_date_parseable?
  end

  def parse_birth_date
    bdate = ParseDate.parsedate(birth_date)
    unless bdate[0] and bdate[1] and bdate[2]
      errors.add(:birth_date, :invalid_birthdate)
    end
    if bdate[0] && bdate[0] < 100
      errors.add(:birth_date, :two_digit_year)
    end
  end

  def birth_date_parseable?
    !birth_date.blank? and birth_date.is_a?(String)
  end

  # DEBT: would like to be able to just pass this obj to searches
  def to_hash
    returning({}) do |h|
      h[:last_name] = last_name
      h[:first_name] = first_name
      h[:birth_date] = birth_date
      h[:use_starts_with_search] = uses_starts_with_search? ? 'true' : nil
      h[:page_size] = page_size
      h[:page] = page
    end
  end

  alias_method :[], :send
end
