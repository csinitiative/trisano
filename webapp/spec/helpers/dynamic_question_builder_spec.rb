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
