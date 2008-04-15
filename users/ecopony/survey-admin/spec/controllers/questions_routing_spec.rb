require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionsController do
  describe "route generation" do

    it "should map { :controller => 'questions', :action => 'index' } to /questions" do
      route_for(:controller => "questions", :action => "index").should == "/questions"
    end
  
    it "should map { :controller => 'questions', :action => 'new' } to /questions/new" do
      route_for(:controller => "questions", :action => "new").should == "/questions/new"
    end
  
    it "should map { :controller => 'questions', :action => 'show', :id => 1 } to /questions/1" do
      route_for(:controller => "questions", :action => "show", :id => 1).should == "/questions/1"
    end
  
    it "should map { :controller => 'questions', :action => 'edit', :id => 1 } to /questions/1/edit" do
      route_for(:controller => "questions", :action => "edit", :id => 1).should == "/questions/1/edit"
    end
  
    it "should map { :controller => 'questions', :action => 'update', :id => 1} to /questions/1" do
      route_for(:controller => "questions", :action => "update", :id => 1).should == "/questions/1"
    end
  
    it "should map { :controller => 'questions', :action => 'destroy', :id => 1} to /questions/1" do
      route_for(:controller => "questions", :action => "destroy", :id => 1).should == "/questions/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'questions', action => 'index' } from GET /questions" do
      params_from(:get, "/questions").should == {:controller => "questions", :action => "index"}
    end
  
    it "should generate params { :controller => 'questions', action => 'new' } from GET /questions/new" do
      params_from(:get, "/questions/new").should == {:controller => "questions", :action => "new"}
    end
  
    it "should generate params { :controller => 'questions', action => 'create' } from POST /questions" do
      params_from(:post, "/questions").should == {:controller => "questions", :action => "create"}
    end
  
    it "should generate params { :controller => 'questions', action => 'show', id => '1' } from GET /questions/1" do
      params_from(:get, "/questions/1").should == {:controller => "questions", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'questions', action => 'edit', id => '1' } from GET /questions/1;edit" do
      params_from(:get, "/questions/1/edit").should == {:controller => "questions", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'questions', action => 'update', id => '1' } from PUT /questions/1" do
      params_from(:put, "/questions/1").should == {:controller => "questions", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'questions', action => 'destroy', id => '1' } from DELETE /questions/1" do
      params_from(:delete, "/questions/1").should == {:controller => "questions", :action => "destroy", :id => "1"}
    end
  end
end