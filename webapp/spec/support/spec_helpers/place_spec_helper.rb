module PlaceSpecHelper

  def put_unassigned_at_the_bottom(jurisdictions)
    unassigned = jurisdictions.find { |jurisdiction| jurisdiction.read_attribute(:name) == "Unassigned" }
    jurisdictions.insert(jurisdictions.size-1, jurisdictions.delete(unassigned))
    jurisdictions
  end

  def given_an_unassigned_jurisdiction
    unassigned = Place.unassigned_jurisdiction
    if unassigned.nil?
      unassigned = create_jurisdiction_entity(:place_attributes => {:name => 'Unassigned'})
    end
    unassigned
  end
end
