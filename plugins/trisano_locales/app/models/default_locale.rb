class DefaultLocale < ActiveRecord::Base
  reloadable!

  belongs_to :user

  validates_presence_of  :short_name
  validates_inclusion_of :short_name, :in => I18n.selectable_locales.map {|v| v.last}, :allow_blank => true
  attr_protected :short_name

  named_scope :latest, :order => "created_at DESC"

  class << self
    def current
      self.latest.first
    end

    def get_locale_name(short_name)
      I18n.backend.try :lookup, short_name, :locale_name
    end

    def update_locale(locale, user = nil)
      if table_exists?
        instance = current || new
        instance.update_locale(locale, user)
      else
        logger.warn "DefaultLocale table does not exist. Rebuilding database?"
      end
    end

    def update_from_db
      if table_exists?
        I18n.default_locale_without_db = current.to_sym if current
      else
        logger.warn "DefaultLocale table does not exist. Rebuilding database?"
      end
    end
  end

  def short_name
    short_name = read_attribute(:short_name)
    short_name.to_sym if short_name
  end

  def short_name=(value)
    write_attribute(:short_name, value.to_s)
  end

  def locale_name
    self.class.get_locale_name(self.short_name)
  end

  def to_sym
    self.short_name
  end
  alias_method :intern, :to_sym

  def update_locale(locale, user = nil)
    return if self.short_name == locale
    self.short_name = locale
    self.user = user
    save
  end

end
