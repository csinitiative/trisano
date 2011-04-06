module DiseaseSpecHelper

  def create_disease(name)
    disease = Disease.find_by_disease_name(name)
    disease = Factory.create(:disease, :disease_name => name) unless disease
    disease
  end

end
