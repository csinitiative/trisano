# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

class FormsController < AdminController

  def index
    @forms = Form.find(:all, :conditions => {:is_template => true}, :order => "name ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @forms }
    end
  end

  def show
    @form = Form.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @form }
    end
  end

  def new
    @form = Form.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @form }
    end
  end

  def edit
    @form = Form.find(params[:id])
    if not @form.is_template
      render :text => "permission denied: this form id is not a template form", :status => 403
    end
  end

  def create
    @form = Form.new(params[:form])

    respond_to do |format|
      if @form.save_and_initialize_form_elements
        flash[:notice] = 'Form was successfully created.'
        format.html { redirect_to(@form) }
        format.xml  { render :xml => @form, :status => :created, :location => @form }
      else
        @form = post_transaction_refresh(@form, params[:form])
        format.html { render :action => "new" }
        format.xml  { render :xml => @form.errors, :status => :unprocessable_entity }
      end
    end
  end

  def copy
    @original_form = Form.find(params[:id])
    @form = @original_form.copy

    respond_to do |format|
      if @form.save
        flash[:notice] = "Form was successfully copied."
        format.html { render :template => 'forms/edit' }
        format.xml  { render :xml => @form, :status => :created, :location => @form }
      else
        flash[:error] = "Form copy failed"
        format.html { redirect_to(@form) }
        format.xml  { render :xml => @form.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    params[:form][:disease_ids] ||= []
    @form = Form.find(params[:id])

    respond_to do |format|
      if @form.update_attributes(params[:form])
        flash[:notice] = 'Form was successfully updated.'
        format.html { redirect_to(@form) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @form.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @form = Form.find(params[:id])
    @form.destroy

    respond_to do |format|
      format.html { redirect_to(forms_url) }
      format.xml  { head :ok }
    end
  end
  
  def builder
    @form = Form.find(params[:id])
    @form.structure_valid?
    if not @form.is_template
      render :text => "Permission denied: This form id is not a template form", :status => 403
    end
  end
  
  def publish
    @form = Form.find(params[:id])

    if @form.publish
      respond_to do |format|
        flash[:notice] = "Form was successfully published"
        format.html { redirect_to forms_path }
        format.js   { render(:update) {|page| page.redirect_to forms_path} }
      end
    else
      flash[:notice] = "Unable to publish the form"
      respond_to do |format|
        format.html { render :template => "forms/builder" }
        format.js   do
          @rjs_errors = @form.errors
          render :template => "rjs-error"
        end
      end
    end
  end
  
  def rollback
    @form = Form.find(params[:id])
    @rolled_back_form = @form.rollback
    
    if @rolled_back_form
      @form = @rolled_back_form
      redirect_to(builder_path(@form))
    else
      flash[:notice] = 'Unable to roll back the form. Please contact your administrator.'
      redirect_to forms_path
    end
  end

  def export
    @form = Form.find(params[:id])
    export_file_path = @form.export
    if export_file_path
      send_file export_file_path
    else
      flash[:notice] = 'Unable to export the form. Please contact your administrator.'
      redirect_to forms_path
    end
  end
  
  def import
    if params[:form][:import].respond_to?(:empty?)
      flash[:notice] = 'Please navigate to a file to import.'
      redirect_to forms_path
      return
    end
    
    if (@form = Form.import(params[:form][:import]))
      redirect_to(@form)
    else
      flash[:notice] = 'Unable to import the form. Please contact your administrator.'
      redirect_to forms_path
    end
  end
  
  def order_section_children
    @section = FormElement.find(params[:id])
    section_name, section_items = params.find { |k, v| k =~ /children$/ }
    reorder_ids = section_items.collect {|id| id.to_i}
      
    if @section.reorder_element_children(reorder_ids)
      @form = Form.find(@section.form_id)
    else
      @rjs_errors = @section.errors
      flash[:notice] = 'An error occurred during the reordering process.'
      render :template => 'rjs-error'
    end
  end
  
  def to_library
    if params[:group_element_id] == "root"
      @group_element = nil
    else
      @group_element = FormElement.find(params[:group_element_id])
    end
    
    @question_element = FormElement.find(params[:reference_element_id])
    @reference_element = @question_element
    
    if @question_element.add_to_library(@group_element)
      @library_elements = FormElement.roots(:conditions => ["form_id IS NULL"])
      render :partial => "forms/library_elements", :locals => {:direction => :to_library, :type => @reference_element.type }
    else
      flash[:notice] = "Unable to copy #{@question_element.type.humanize} to library."
      render :template => 'rjs-error'
    end
  end

  def from_library
    form_element_id = params[:reference_element_id]
    lib_element_id = params[:lib_element_id]
    @form_element = FormElement.find(form_element_id)
    if @form_element.copy_from_library(lib_element_id)
      @form = Form.find(@form_element.form_id)
    else
      @rjs_errors = @form_element.errors
      flash[:notice] = "Unable to copy element to form."
      render :template => 'rjs-error'
    end
  end
  
  def library_admin
    begin
      @library_elements = FormElement.roots(:conditions => ["form_id IS NULL"])
      @type = params[:type].blank? ? "question_element" : params[:type]
    rescue Exception => ex
      flash[:notice] = "Unable to open the library."
      render :template => 'rjs-error'
    end
  end

end
