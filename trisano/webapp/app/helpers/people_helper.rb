module PeopleHelper

  def add_new_telephone_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :phones, :partial => 'events/telephone', :object => EntitiesLocation.new
    end
  end

end
