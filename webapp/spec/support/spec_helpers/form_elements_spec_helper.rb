# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
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
