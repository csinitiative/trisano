module DiseaseSpecHelper

  def given_a_disease_named(name)
    disease = Disease.find_by_disease_name(name)
    disease = Factory.create(:disease, :disease_name => name) unless disease
    disease
  end

end
