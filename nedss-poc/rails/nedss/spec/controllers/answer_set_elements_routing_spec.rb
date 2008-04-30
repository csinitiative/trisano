require File.dirname(__FILE__) + '/../spec_helper'

describe AnswerSetElementsController do
  describe "route generation" do

    it "should map { :controller => 'answer_set_elements', :action => 'index' } to /answer_set_elements" do
      route_for(:controller => "answer_set_elements", :action => "index").should == "/answer_set_elements"
    end
  
    it "should map { :controller => 'answer_set_elements', :action => 'new' } to /answer_set_elements/new" do
      route_for(:controller => "answer_set_elements", :action => "new").should == "/answer_set_elements/new"
    end
  
    it "should map { :controller => 'answer_set_elements', :action => 'show', :id => 1 } to /answer_set_elements/1" do
      route_for(:controller => "answer_set_elements", :action => "show", :id => 1).should == "/answer_set_elements/1"
    end
  
    it "should map { :controller => 'answer_set_elements', :action => 'edit', :id => 1 } to /answer_set_elements/1/edit" do
      route_for(:controller => "answer_set_elements", :action => "edit", :id => 1).should == "/answer_set_elements/1/edit"
    end
  
    it "should map { :controller => 'answer_set_elements', :action => 'update', :id => 1} to /answer_set_elements/1" do
      route_for(:controller => "answer_set_elements", :action => "update", :id => 1).should == "/answer_set_elements/1"
    end
  
    it "should map { :controller => 'answer_set_elements', :action => 'destroy', :id => 1} to /answer_set_elements/1" do
      route_for(:controller => "answer_set_elements", :action => "destroy", :id => 1).should == "/answer_set_elements/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'answer_set_elements', action => 'index' } from GET /answer_set_elements" do
      params_from(:get, "/answer_set_elements").should == {:controller => "answer_set_elements", :action => "index"}
    end
  
    it "should generate params { :controller => 'answer_set_elements', action => 'new' } from GET /answer_set_elements/new" do
      params_from(:get, "/answer_set_elements/new").should == {:controller => "answer_set_elements", :action => "new"}
    end
  
    it "should generate params { :controller => 'answer_set_elements', action => 'create' } from POST /answer_set_elements" do
      params_from(:post, "/answer_set_elements").should == {:controller => "answer_set_elements", :action => "create"}
    end
  
    it "should generate params { :controller => 'answer_set_elements', action => 'show', id => '1' } from GET /answer_set_elements/1" do
      params_from(:get, "/answer_set_elements/1").should == {:controller => "answer_set_elements", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'answer_set_elements', action => 'edit', id => '1' } from GET /answer_set_elements/1;edit" do
      params_from(:get, "/answer_set_elements/1/edit").should == {:controller => "answer_set_elements", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'answer_set_elements', action => 'update', id => '1' } from PUT /answer_set_elements/1" do
      params_from(:put, "/answer_set_elements/1").should == {:controller => "answer_set_elements", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'answer_set_elements', action => 'destroy', id => '1' } from DELETE /answer_set_elements/1" do
      params_from(:delete, "/answer_set_elements/1").should == {:controller => "answer_set_elements", :action => "destroy", :id => "1"}
    end
  end
end