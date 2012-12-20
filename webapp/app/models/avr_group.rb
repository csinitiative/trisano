class AvrGroup < ActiveRecord::Base
  has_and_belongs_to_many :diseases

  validates_presence_of :name
  validates_uniqueness_of :name
  validate :name_is_not_trisano

  def name_is_not_trisano
    errors.add(:name, "cannot include 'TriSano'") if name.include?("TriSano")
  end


  def self.std
    find_by_name("STD Data")
  end
end
