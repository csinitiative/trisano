class DefaultLocale < ActiveRecord::Base
  reloadable!

  after_save :update_default_locale

  belongs_to :user

  validates_presence_of  :short_name
  validates_inclusion_of :short_name, :in => I18n.selectable_locales.map {|v| v.last.to_s}, :allow_blank => true
  attr_protected :short_name

  named_scope :latest, :order => "created_at DESC"

  class << self
    def current
      self.latest.first
    end

    def get_locale_name(short_name)
      I18n.backend.try :lookup, short_name, :locale_name
    end

  end

  def short_name
    read_attribute(:short_name).to_s
  end

  def short_name=(value)
    write_attribute(:short_name, value.to_s)
  end

  def locale_name
    self.class.get_locale_name(self.short_name)
  end

  def to_sym
    self.short_name.to_sym
  end
  alias_method :intern, :to_sym

  def update_default_locale
    I18n.default_locale_without_db = self.to_sym
  end

  def update_locale(locale, user = nil)
    self.short_name = locale
    self.user = user
    save
  end

end
