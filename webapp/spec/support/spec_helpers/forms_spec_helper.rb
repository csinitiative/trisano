module FormsSpecHelper

  # Bypass nested set logic to invalidate the provided form.
  def invalidate_form(form)
    ActiveRecord::Base.connection.execute("update form_elements set parent_id = null where id = #{form.investigator_view_elements_container.id}")
  end

  # Bypass nested set logic to invalidate the provided tree's root
  def invalidate_tree(tree_root)
    ActiveRecord::Base.connection.execute("update form_elements set rgt = 1 where id = #{tree_root.id}")
  end

end
