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
    return unless birth_date_parseable?
    validate_date
  end

  def bdate_array
    @bdate_array ||= ValidatesTimeliness::Formats.parse(birth_date, :date)
  end

  def validate_date
    unless bdate_array
      errors.add(:birth_date, :invalid_date)
    end
  end

  def birth_date_parseable?
    !birth_date.blank? and birth_date.is_a?(String)
  end

  def normalized_birth_date
    return unless bdate_array
    DateTime.civil(*bdate_array).to_date
  end

  # DEBT: would like to be able to just pass this obj to searches
  def to_hash
    returning({}) do |h|
      h[:last_name] = last_name
      h[:first_name] = first_name
      h[:birth_date] = normalized_birth_date
      h[:use_starts_with_search] = uses_starts_with_search? ? 'true' : nil
      h[:page_size] = page_size
      h[:page] = page
    end
  end

  alias_method :[], :send
end
