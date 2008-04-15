require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionTypesController do
  describe "route generation" do

    it "should map { :controller => 'question_types', :action => 'index' } to /question_types" do
      route_for(:controller => "question_types", :action => "index").should == "/question_types"
    end
  
    it "should map { :controller => 'question_types', :action => 'new' } to /question_types/new" do
      route_for(:controller => "question_types", :action => "new").should == "/question_types/new"
    end
  
    it "should map { :controller => 'question_types', :action => 'show', :id => 1 } to /question_types/1" do
      route_for(:controller => "question_types", :action => "show", :id => 1).should == "/question_types/1"
    end
  
    it "should map { :controller => 'question_types', :action => 'edit', :id => 1 } to /question_types/1/edit" do
      route_for(:controller => "question_types", :action => "edit", :id => 1).should == "/question_types/1/edit"
    end
  
    it "should map { :controller => 'question_types', :action => 'update', :id => 1} to /question_types/1" do
      route_for(:controller => "question_types", :action => "update", :id => 1).should == "/question_types/1"
    end
  
    it "should map { :controller => 'question_types', :action => 'destroy', :id => 1} to /question_types/1" do
      route_for(:controller => "question_types", :action => "destroy", :id => 1).should == "/question_types/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'question_types', action => 'index' } from GET /question_types" do
      params_from(:get, "/question_types").should == {:controller => "question_types", :action => "index"}
    end
  
    it "should generate params { :controller => 'question_types', action => 'new' } from GET /question_types/new" do
      params_from(:get, "/question_types/new").should == {:controller => "question_types", :action => "new"}
    end
  
    it "should generate params { :controller => 'question_types', action => 'create' } from POST /question_types" do
      params_from(:post, "/question_types").should == {:controller => "question_types", :action => "create"}
    end
  
    it "should generate params { :controller => 'question_types', action => 'show', id => '1' } from GET /question_types/1" do
      params_from(:get, "/question_types/1").should == {:controller => "question_types", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'question_types', action => 'edit', id => '1' } from GET /question_types/1;edit" do
      params_from(:get, "/question_types/1/edit").should == {:controller => "question_types", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'question_types', action => 'update', id => '1' } from PUT /question_types/1" do
      params_from(:put, "/question_types/1").should == {:controller => "question_types", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'question_types', action => 'destroy', id => '1' } from DELETE /question_types/1" do
      params_from(:delete, "/question_types/1").should == {:controller => "question_types", :action => "destroy", :id => "1"}
    end
  end
end