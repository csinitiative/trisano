module PlaceSpecHelper

  def put_unassigned_at_the_bottom(jurisdictions)
    unassigned = jurisdictions.find { |jurisdiction| jurisdiction.read_attribute(:name) == "Unassigned" }
    jurisdictions.insert(jurisdictions.size-1, jurisdictions.delete(unassigned))
    jurisdictions
  end

end
