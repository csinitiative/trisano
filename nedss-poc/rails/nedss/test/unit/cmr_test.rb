require File.dirname(__FILE__) + '/../test_helper'
require 'chronic'

class CmrTest < ActiveSupport::TestCase
  
  fixtures(:cmrs)
  
  def setup
    @cmr = Cmr.find(1)
  end
  
  def test_create
    assert_kind_of(Cmr, (@cmr))
    assert_equal(cmrs(:basic_cmr).id, @cmr.id)
    assert_equal(cmrs(:basic_cmr).first_name, @cmr.first_name)
    # This will fail. Does the fixture creation process not use the model?
    # assert_not_equal("", @cmr.accession_number)
  end
  
  def test_accession_number_generation
    @cmr = Cmr.new(:first_name => "Bob", :date_of_birth => "November 11, 1987")
    @cmr.save
    @cmr.reload
    assert_not_equal("", @cmr.accession_number)
  end
  
  def test_age_generation
    birth_date = Chronic.parse("33 years ago")
    @cmr.date_of_birth = birth_date
    @cmr.save
    @cmr.reload
    assert_equal(33, @cmr.age)
  end
  
  def test_natural_language_date_parsing
    @cmr.date_of_birth = "bad date"
    assert(!@cmr.save, @cmr.errors.full_messages.join("; "))
    @cmr.date_of_birth = "11-25-1974"
    assert(!@cmr.save, @cmr.errors.full_messages.join("; "))
    @cmr.date_of_birth = "nov 25, 1974"
    assert(@cmr.save, @cmr.errors.full_messages.join("; "))
    @cmr.date_of_birth = "november 25, 1974"
    assert(@cmr.save, @cmr.errors.full_messages.join("; "))
    @cmr.date_of_birth = "1974-11-25"
    assert(@cmr.save, @cmr.errors.full_messages.join("; "))
    @cmr.date_of_birth = "11/25/1974"
    assert(@cmr.save, @cmr.errors.full_messages.join("; "))
  end
  
  def test_update
    assert_equal(cmrs(:basic_cmr).first_name, @cmr.first_name)
    @cmr.first_name = "Lenny"
    assert(@cmr.save, @cmr.errors.full_messages.join("; "))
    @cmr.reload
    assert_equal("Lenny", @cmr.first_name)
  end
  
  def test_destroy
    @cmr.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Cmr.find(@cmr.id) }
  end
  
  def test_validate
    assert_equal(cmrs(:basic_cmr).first_name, @cmr.first_name)
    @cmr.first_name = ""
    assert(!@cmr.save)
    assert_equal(1, @cmr.errors.count)
  end
  
end
