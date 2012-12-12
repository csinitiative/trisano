require 'active_support/core_ext'
require 'lib/trisano'
require 'lib/trisano/nested_attributes_helper'
include Trisano::NestedAttributesHelper

describe "nested_attributes_blank?" do

  it "returns false when new_repeater_checkboxes check_box_answer is present" do
    sample_params = {"new_repeater_checkboxes"=>{"3962"=>{"code"=>"", "event_id"=>"78", "check_box_answer"=>["A"]}}}
    nested_attributes_blank?(sample_params).should be_false 
  end

  it "returns true when new_repeater_checkboxes check_box_answer is blank" do
    sample_params = {"new_repeater_checkboxes"=>{"3962"=>{"code"=>"", "event_id"=>"78", "check_box_answer"=>[""]}}}
    nested_attributes_blank?(sample_params).should be_true 
  end

  it "returns false when new_repeater_radio_buttons radio_button_answer is present" do
    sample_params = {"new_repeater_radio_buttons"=>{"3961"=>{"code"=>"", "event_id"=>"78", "radio_button_answer"=>["A"]}}}
    nested_attributes_blank?(sample_params).should be_false 
  end

  it "returns true when new_repeater_radio_buttons radio_button_answer is blank" do
    sample_params = {"new_repeater_radio_buttons"=>{"3961"=>{"code"=>"", "event_id"=>"78", "radio_button_answer"=>[""]}}}
    nested_attributes_blank?(sample_params).should be_true 
  end

  it "returns false when new_repeater_answers text_answer is present" do
    sample_params = {"new_repeater_answers"=>[{"event_id"=>"78", "question_id"=>"3959", "text_answer"=>"asdf"}, {"code"=>"a", "event_id"=>"78", "question_id"=>"3960", "text_answer"=>"a"}, {"event_id"=>"78", "question_id"=>"3963", "text_answer"=>""}]}
    nested_attributes_blank?(sample_params).should be_false 
  end

  it "returns true when new_repeater_answers text_answer is blank" do
    sample_params = {"new_repeater_answers"=>[{"event_id"=>"78", "question_id"=>"3959", "text_answer"=>""}, {"code"=>"a", "event_id"=>"78", "question_id"=>"3960", "text_answer"=>""}, {"event_id"=>"78", "question_id"=>"3963", "text_answer"=>""}]}
    nested_attributes_blank?(sample_params).should be_true 
  end

  it "returns false when any attributes are present" do
    sample_params = {"email_address"=>"qwer", "something_else" => ""}
    nested_attributes_blank?(sample_params).should be_false 
  end

  it "returns true when all attributes are blank" do
    sample_params = {"email_address"=>"", "something_else" => ""}
    nested_attributes_blank?(sample_params).should be_true 
  end

  it "returns false when complex combinations are present" do
    sample_params = {"new_repeater_answers"=>[{"event_id"=>"78", "question_id"=>"3959", "text_answer"=>"asdf"}, {"code"=>"a", "event_id"=>"78", "question_id"=>"3960", "text_answer"=>"a"}, {"event_id"=>"78", "question_id"=>"3963", "text_answer"=>""}], "new_repeater_radio_buttons"=>{"3961"=>{"code"=>"", "event_id"=>"78", "radio_button_answer"=>[""]}}, "email_address"=>"", "new_repeater_checkboxes"=>{"3962"=>{"code"=>"", "event_id"=>"78", "check_box_answer"=>[""]}}}
    nested_attributes_blank?(sample_params).should be_false 
  end

  it "returns true when complex combinations are blank" do
    sample_params = {"new_repeater_answers"=>[{"event_id"=>"78", "question_id"=>"3959", "text_answer"=>""}, {"code"=>"a", "event_id"=>"78", "question_id"=>"3960", "text_answer"=>""}, {"event_id"=>"78", "question_id"=>"3963", "text_answer"=>""}], "new_repeater_radio_buttons"=>{"3961"=>{"code"=>"", "event_id"=>"78", "radio_button_answer"=>[""]}}, "email_address"=>"", "new_repeater_checkboxes"=>{"3962"=>{"code"=>"", "event_id"=>"78", "check_box_answer"=>[""]}}}
    nested_attributes_blank?(sample_params).should be_true 
  end

  it "returns true when nil is passed" do
    nested_attributes_blank?(nil).should be_true
  end

  it "ignores position as a key" do
    sample_params = {"lab_result"=>"", "position" => "1"}
    nested_attributes_blank?(sample_params).should be_true 
  end
end
