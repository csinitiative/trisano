module FormElementsSpecHelper

  def assert_element_shallow_copy(original, copy)
    copy.should_not == original
    copy.form_id.should be_nil
    copy.name.should == original.name
    copy.description.should == original.description
    copy.help_text.should == original.help_text
    copy.condition.should == original.condition
    copy.core_path.should == original.core_path
    copy.is_active.should == original.is_active
    copy.is_condition_code.should == original.is_condition_code
    copy.export_column_id.should == original.export_column_id
    copy.export_conversion_value_id.should == original.export_conversion_value_id
    copy.code.should == original.code
  end

  def assert_element_in_tree(element, tree_id)
    err_msg = "Element expected to be in tree '#{tree_id}', was actually in '#{element.tree_id}'"
    assert_block(err_msg) do
      element.tree_id == tree_id
    end
  end

  def assert_question_is_a_copy(original, copy)
    assert_block("Expects #{copy} to be a copy of #{original}, but is the same record") do
      copy != original
    end
    %w(question_text
       data_type
       size
       is_required
       core_data
       core_data_attr
       short_name
       style).each do |meth|
      if original.send(meth) != copy.send(meth)
        msg = build_message("'#{meth}' attribute not equal.",
                            "Expected ? and got ?",
                            original.send(meth),
                            copy.send(meth))
        flunk msg
      end
    end
  end

  def assert_element_deep_copy(original, copy)
    original.children.each_with_index do |child, i|
      copy_child = copy.children[i]
      assert_element_shallow_copy(child, copy_child)
      assert_element_deep_copy(child, copy_child)
      if child.is_a?(QuestionElement)
        assert_question_is_a_copy(child.question, copy_child.question)
      end
    end
  end

end
