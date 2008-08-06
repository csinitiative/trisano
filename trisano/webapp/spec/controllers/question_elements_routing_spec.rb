require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionElementsController do
  describe "route generation" do

    it "should map { :controller => 'question_elements', :action => 'index' } to /question_elements" do
      route_for(:controller => "question_elements", :action => "index").should == "/question_elements"
    end
  
    it "should map { :controller => 'question_elements', :action => 'new' } to /question_elements/new" do
      route_for(:controller => "question_elements", :action => "new").should == "/question_elements/new"
    end
  
    it "should map { :controller => 'question_elements', :action => 'show', :id => 1 } to /question_elements/1" do
      route_for(:controller => "question_elements", :action => "show", :id => 1).should == "/question_elements/1"
    end
  
    it "should map { :controller => 'question_elements', :action => 'edit', :id => 1 } to /question_elements/1/edit" do
      route_for(:controller => "question_elements", :action => "edit", :id => 1).should == "/question_elements/1/edit"
    end
  
    it "should map { :controller => 'question_elements', :action => 'update', :id => 1} to /question_elements/1" do
      route_for(:controller => "question_elements", :action => "update", :id => 1).should == "/question_elements/1"
    end
  
    it "should map { :controller => 'question_elements', :action => 'destroy', :id => 1} to /question_elements/1" do
      route_for(:controller => "question_elements", :action => "destroy", :id => 1).should == "/question_elements/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'question_elements', action => 'index' } from GET /question_elements" do
      params_from(:get, "/question_elements").should == {:controller => "question_elements", :action => "index"}
    end
  
    it "should generate params { :controller => 'question_elements', action => 'new' } from GET /question_elements/new" do
      params_from(:get, "/question_elements/new").should == {:controller => "question_elements", :action => "new"}
    end
  
    it "should generate params { :controller => 'question_elements', action => 'create' } from POST /question_elements" do
      params_from(:post, "/question_elements").should == {:controller => "question_elements", :action => "create"}
    end
  
    it "should generate params { :controller => 'question_elements', action => 'show', id => '1' } from GET /question_elements/1" do
      params_from(:get, "/question_elements/1").should == {:controller => "question_elements", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'question_elements', action => 'edit', id => '1' } from GET /question_elements/1;edit" do
      params_from(:get, "/question_elements/1/edit").should == {:controller => "question_elements", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'question_elements', action => 'update', id => '1' } from PUT /question_elements/1" do
      params_from(:put, "/question_elements/1").should == {:controller => "question_elements", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'question_elements', action => 'destroy', id => '1' } from DELETE /question_elements/1" do
      params_from(:delete, "/question_elements/1").should == {:controller => "question_elements", :action => "destroy", :id => "1"}
    end
  end
end