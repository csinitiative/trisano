module XmlSpecHelper
  def assert_xml_field(css_path, field, rel=nil)
    if rel
     response.body.should have_css("#{css_path} #{field.to_s.dasherize}[rel='#{rel}']")
     response.body.should have_css("morbidity-event atom|link[rel='#{rel}']")
    else
     response.body.should have_css("#{css_path} #{field.to_s.dasherize}")
    end
  end

end
