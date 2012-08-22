require File.expand_path("../../../app/helpers/dynamic_question_builder", __FILE__)
describe DynamicQuestionBuilder do
  describe "#question_is_multi_valued_and_has_value_set?" do
    let(:question_element) { stub :question_element, :question => question }
    let(:form_elements_cache) { stub :form_elements_cache }
    let(:builder) { DynamicQuestionBuilder.new(:question_element => question_element, :form_elements_cache => form_elements_cache) } 
    let(:result) { builder.question_is_multi_valued_and_has_value_set? }
    
    context "question is not multi valued" do

     let(:question) { stub :question, :is_multi_valued? => false }

      it "return false" do
        result.should be_false
      end
    end #not multi valued question

    context "question is multi valued" do

       let(:question) { stub :question, :is_multi_valued? => true }
 

       context "question element has children" do

         before do
       
           # TODO: form_elements_cache.has_children_for?(question_element)
           form_elements_cache.stub!(:has_children_for?).with(question_element).and_return(true)
 
         end

         context "question element has value set" do

           before do
             # TODO: form_elements_cache.has_children_for?(question_element)
             form_elements_cache.stub!(:has_value_set_for?).with(question_element).and_return(true)
           end 

           it "returns true" do
             result.should be_true
           end


         end

         context "question element has no value set" do

           before do
             # TODO: form_elements_cache.has_children_for?(question_element)
             form_elements_cache.stub!(:has_value_set_for?).with(question_element).and_return(false)
           end 

           it "returns false" do
             result.should be_false
           end


         end
         
       end #has children

       context "question element has no children" do

         before do
       
           # TODO: form_elements_cache.has_children_for?(question_element)
           form_elements_cache.stub!(:has_children_for?).with(question_element).and_return(false)
 
         end

         it "returns false" do

           result.should be_false

         end

       end # no children 
     
    end #multi valued question
  end
end
