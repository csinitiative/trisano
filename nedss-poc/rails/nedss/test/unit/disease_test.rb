require File.dirname(__FILE__) + '/../test_helper'

class DiseaseTest < ActiveSupport::TestCase

  fixtures(:diseases)
  
  def setup
    @disease = Disease.find(1)
  end
  
  def test_create
    assert_kind_of(Disease, (@disease))
    assert_equal(diseases(:basic_disease).id, @disease.id)
    assert_equal(diseases(:basic_disease).name, @disease.name)
  end
  
  def test_update
    assert_equal(diseases(:basic_disease).name, @disease.name)
    @disease.name = "Meningitis"
    assert(@disease.save, @disease.errors.full_messages.join("; "))
    @disease.reload
    assert_equal("Meningitis", @disease.name)
  end
  
  def test_destroy
    @disease.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Disease.find(@disease.id) }
  end
  
  def test_validate
    assert_equal(diseases(:basic_disease).name, @disease.name)
    @disease.name = ""
    assert(!@disease.save)
    assert_equal(1, @disease.errors.count)
  end
  
end
