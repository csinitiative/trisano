@test_types = {}
CommonTestType.all.each { |ctt| @test_types[ctt.common_name] = ctt.id }

HumanEvent.all(
  :include => [ :disease_event => :disease ],
  :conditions => [ "diseases.disease_name LIKE ?", 'Tuberculosis%' ]).each do |event|

  event.lab_results.each do |lr|
    print '.'
    if lr.comment =~ /Test Type: .*chest|cxr|radio|ray.*, Test Result/
      if lr.test_type_id == @test_types['Acid fast stain']
        lr.update_attribute(:test_type_id, @test_types['Chest X-ray'])
      end
    end
  end
end
puts ""
