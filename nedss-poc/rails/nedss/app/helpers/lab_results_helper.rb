module LabResultsHelper
  def add_lab_result_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, "lab-result-list", :partial => 'lab_result' , :object => LabResult.new
    end
  end
end
