require File.dirname(__FILE__) + '/../spec_helper'

describe AnswerSetsController do
  describe "route generation" do

    it "should map { :controller => 'answer_sets', :action => 'index' } to /answer_sets" do
      route_for(:controller => "answer_sets", :action => "index").should == "/answer_sets"
    end
  
    it "should map { :controller => 'answer_sets', :action => 'new' } to /answer_sets/new" do
      route_for(:controller => "answer_sets", :action => "new").should == "/answer_sets/new"
    end
  
    it "should map { :controller => 'answer_sets', :action => 'show', :id => 1 } to /answer_sets/1" do
      route_for(:controller => "answer_sets", :action => "show", :id => 1).should == "/answer_sets/1"
    end
  
    it "should map { :controller => 'answer_sets', :action => 'edit', :id => 1 } to /answer_sets/1/edit" do
      route_for(:controller => "answer_sets", :action => "edit", :id => 1).should == "/answer_sets/1/edit"
    end
  
    it "should map { :controller => 'answer_sets', :action => 'update', :id => 1} to /answer_sets/1" do
      route_for(:controller => "answer_sets", :action => "update", :id => 1).should == "/answer_sets/1"
    end
  
    it "should map { :controller => 'answer_sets', :action => 'destroy', :id => 1} to /answer_sets/1" do
      route_for(:controller => "answer_sets", :action => "destroy", :id => 1).should == "/answer_sets/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'answer_sets', action => 'index' } from GET /answer_sets" do
      params_from(:get, "/answer_sets").should == {:controller => "answer_sets", :action => "index"}
    end
  
    it "should generate params { :controller => 'answer_sets', action => 'new' } from GET /answer_sets/new" do
      params_from(:get, "/answer_sets/new").should == {:controller => "answer_sets", :action => "new"}
    end
  
    it "should generate params { :controller => 'answer_sets', action => 'create' } from POST /answer_sets" do
      params_from(:post, "/answer_sets").should == {:controller => "answer_sets", :action => "create"}
    end
  
    it "should generate params { :controller => 'answer_sets', action => 'show', id => '1' } from GET /answer_sets/1" do
      params_from(:get, "/answer_sets/1").should == {:controller => "answer_sets", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'answer_sets', action => 'edit', id => '1' } from GET /answer_sets/1;edit" do
      params_from(:get, "/answer_sets/1/edit").should == {:controller => "answer_sets", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'answer_sets', action => 'update', id => '1' } from PUT /answer_sets/1" do
      params_from(:put, "/answer_sets/1").should == {:controller => "answer_sets", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'answer_sets', action => 'destroy', id => '1' } from DELETE /answer_sets/1" do
      params_from(:delete, "/answer_sets/1").should == {:controller => "answer_sets", :action => "destroy", :id => "1"}
    end
  end
end