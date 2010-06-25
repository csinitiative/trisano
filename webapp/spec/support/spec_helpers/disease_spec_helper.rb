module DiseaseSpecHelper

  def given_a_disease_named(name)
    unless Disease.find_by_disease_name(name)
      Factory.create(:disease, :disease_name => name)
    end
  end

end
