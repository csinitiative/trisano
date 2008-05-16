class CoreDataElement < FormElement
  has_one :question, :foreign_key => "question_element_id"
end
