require File.expand_path("../../../app/helpers/dynamic_question_builder", __FILE__)
require 'mocha'
describe DynamicQuestionBuilder do
  describe "#question_is_multi_valued_and_has_value_set?" do
     let(:question_element) { stub(:question => question) }
     let(:form_elements_cache) { stub }
     let(:builder) { DynamicQuestionBuilder.new(:question_element => question_element, :form_elements_cache => form_elements_cache) }
     let(:result) { builder.question_is_multi_valued_and_has_no_value_set? }
    
    context "question is not multi valued" do
      let(:question) { stub(:is_multi_valued? => false) }
      it "return false" do
        result.should be_false
      end
    end #not multi valued question

    context "question is multi valued" do

       let(:question) { stub(:is_multi_valued? => true) }
 

       context "question element has children" do
         before do
           form_elements_cache.stubs(:has_children_for?).with(question_element).returns(true)
         end


         context "question element has value set" do
           before do
             form_elements_cache.stubs(:has_value_set_for?).with(question_element).returns(true)
           end 
           it "returns false" do
             result.should be_false
           end
         end


         context "question element has no value set" do
           before do
             form_elements_cache.stubs(:has_value_set_for?).with(question_element).returns(false)
           end 
           it "returns true" do
             result.should be_true
           end
         end
       end #has children




       context "question element has no children" do
         before do
           form_elements_cache.stubs(:has_value_set_for?).with(question_element).returns(false)
         end
         it "returns true" do
           result.should be_true
         end

       end # no children 
    end #multi valued question
  end
end
