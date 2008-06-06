class GroupElement < FormElement

  attr_accessor :parent_element_id

  validates_presence_of :name

  def save_and_add_to_form
    if self.valid?
      transaction do
        self.tree_id = Form.find_by_sql("SELECT nextval('tree_id_generator')").first.nextval.to_i
        self.save
      end
    end
  end
end
