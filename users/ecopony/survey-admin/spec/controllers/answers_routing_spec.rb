require File.dirname(__FILE__) + '/../spec_helper'

describe AnswersController do
  describe "route generation" do

    it "should map { :controller => 'answers', :action => 'index' } to /answers" do
      route_for(:controller => "answers", :action => "index").should == "/answers"
    end
  
    it "should map { :controller => 'answers', :action => 'new' } to /answers/new" do
      route_for(:controller => "answers", :action => "new").should == "/answers/new"
    end
  
    it "should map { :controller => 'answers', :action => 'show', :id => 1 } to /answers/1" do
      route_for(:controller => "answers", :action => "show", :id => 1).should == "/answers/1"
    end
  
    it "should map { :controller => 'answers', :action => 'edit', :id => 1 } to /answers/1/edit" do
      route_for(:controller => "answers", :action => "edit", :id => 1).should == "/answers/1/edit"
    end
  
    it "should map { :controller => 'answers', :action => 'update', :id => 1} to /answers/1" do
      route_for(:controller => "answers", :action => "update", :id => 1).should == "/answers/1"
    end
  
    it "should map { :controller => 'answers', :action => 'destroy', :id => 1} to /answers/1" do
      route_for(:controller => "answers", :action => "destroy", :id => 1).should == "/answers/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'answers', action => 'index' } from GET /answers" do
      params_from(:get, "/answers").should == {:controller => "answers", :action => "index"}
    end
  
    it "should generate params { :controller => 'answers', action => 'new' } from GET /answers/new" do
      params_from(:get, "/answers/new").should == {:controller => "answers", :action => "new"}
    end
  
    it "should generate params { :controller => 'answers', action => 'create' } from POST /answers" do
      params_from(:post, "/answers").should == {:controller => "answers", :action => "create"}
    end
  
    it "should generate params { :controller => 'answers', action => 'show', id => '1' } from GET /answers/1" do
      params_from(:get, "/answers/1").should == {:controller => "answers", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'answers', action => 'edit', id => '1' } from GET /answers/1;edit" do
      params_from(:get, "/answers/1/edit").should == {:controller => "answers", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'answers', action => 'update', id => '1' } from PUT /answers/1" do
      params_from(:put, "/answers/1").should == {:controller => "answers", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'answers', action => 'destroy', id => '1' } from DELETE /answers/1" do
      params_from(:delete, "/answers/1").should == {:controller => "answers", :action => "destroy", :id => "1"}
    end
  end
end