# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
      format.html
      format.xml  { render :xml => @forms }
    end
  end

  def show
    @form = Form.find(params[:id])
    @form.structure_valid?
    if not @form.is_template
      render :partial => "events/permission_denied", :locals => { :reason => t("not_a_template_form"), :event => nil }, :layout => true, :status => 403 and return
    end
  end

  def new
    @form = Form.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @form }
    end
  end

  def edit
    @form = Form.find(params[:id])
    if not @form.is_template
      render :partial => "events/permission_denied", :locals => { :reason => t("not_a_template_form"), :event => nil }, :layout => true, :status => 403 and return
    end
  end

  def create
    @form = Form.new(params[:form])

    respond_to do |format|
      if @form.save_and_initialize_form_elements
        redis.delete_matched("views/events/*")

        flash[:notice] = t("form_created")
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
        redis.delete_matched("views/events/*")

        flash[:notice] = t("form_copy_successful")
        format.html { redirect_to(edit_form_path(@form)) }
        format.xml  { render :xml => @form, :status => :created, :location => @form }
      else
        flash[:error] = t("form_copy_failed")
        format.html { redirect_to(@form) }
        format.xml  { render :xml => @form.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    params[:form][:diseases_forms_attributes]  ||= []
    params[:form][:diseases_forms_attributes].each {|f| f[:auto_assign] ||= false }
    @form = Form.find(params[:id])

    respond_to do |format|
      if @form.update_attributes(params[:form])
        redis.delete_matched("views/events/*")

        flash[:notice] = t("form_updated")
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
    redis.delete_matched("views/events/*")

    respond_to do |format|
      format.html { redirect_to(forms_url) }
      format.xml  { head :ok }
    end
  end

  def builder
    @form = Form.find(params[:id])
    @form.structure_valid?
    if not @form.is_template
      render :partial => "events/permission_denied", :locals => { :reason => t("not_a_template_form"), :event => nil }, :layout => true, :status => 403 and return
    end
  end

  def publish
    @form = Form.find(params[:id])

    if @form.publish
      redis.delete_matched("views/events/*")

      respond_to do |format|
        flash[:notice] = t("form_publish_successful")
        format.html { redirect_to forms_path }
        format.js   { render(:update) {|page| page.redirect_to forms_path} }
      end
    else
      flash[:error] = t("form_publish_failed")
      respond_to do |format|
        format.html { render :template => "forms/builder" }
        format.js   do
          @rjs_errors = @form.errors
          render :template => "rjs-error"
        end
      end
    end
  end

  def push
    @form = Form.find(params[:id])

    if @form.push
      redis.delete_matched("views/events/*")

      respond_to do |format|
        flash[:notice] = t("form_push_successful")
        format.html { redirect_to forms_path }
        format.js   { render(:update) {|page| page.redirect_to forms_path} }
      end
    else
      flash[:error] = t("form_push_failed")
      respond_to do |format|
        format.html { redirect_to forms_path }
        format.js   do
          @rjs_errors = @form.errors
          render :template => "rjs-error"
        end
      end
    end
  end

  def deactivate
    @form = Form.find(params[:id])

    if @form.deactivate
      redis.delete_matched("views/events/*")

      respond_to do |format|
        flash[:notice] = t("form_deactivation_successful")
        format.html { redirect_to forms_path }
        format.js   { render(:update) {|page| page.redirect_to forms_path} }
      end
    else
      flash[:error] = t("form_deactivation_failed")
      respond_to do |format|
        format.html { redirect_to forms_path }
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
    redis.delete_matched("views/events/*")

    if @rolled_back_form
      @form = @rolled_back_form
      redirect_to(builder_path(@form))
    else
      flash[:error] = t("form_rollback_failed")
      redirect_to forms_path
    end
  end

  def export
    @form = Form.find(params[:id])
    export_file_path = @form.export

    if export_file_path
      response.headers['Content-type'] = "application/zip"
      send_file export_file_path
      #head :ok    # Makes RSpec happy with rails 2.3, but breaks behavior in browser
    else
      error_message = t("form_export_failed")
      error_message << " #{@form.errors["base"]}" unless @form.errors.empty?
      flash[:error] = error_message
      redirect_to forms_path
    end
  end

  def import
    if params[:form].nil? || params[:form][:import].respond_to?(:empty?)
      flash[:error] = t("navigate_to_form_to_import")
      redirect_to forms_path
      return
    end

    begin
      @form = Form.import(params[:form][:import])
      redis.delete_matched("views/events/*")

      redirect_to(@form)
    rescue Exception => ex
      flash[:error] = t("form_import_failed", :message => ex.message)
      redirect_to forms_path
    end
  end

  def order_section_children
    @section = FormElement.find(params[:id])
    reorder_ids = params[:question].collect {|id| id.to_i}
    if @section.reorder_element_children(reorder_ids)
      @form = Form.find(@section.form_id)
    else
      @rjs_errors = @section.errors
      flash[:error] = t("reordering_failed")
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
      redis.delete_matched("views/events/*")

      @library_elements = FormElement.library_roots
      render :partial => "forms/library_elements", :locals => {:direction => :to_library, :type => @reference_element.class.name }
    else
      flash[:error] = t("library_copy_failed", :type => @question_element.class.human_name)
      render(:template => 'rjs-error', :status => :bad_request)
    end
  end

  def from_library
    @form_element = FormElement.find(params[:reference_element_id])
    @lib_element = FormElement.find(params[:lib_element_id])

    begin
      @compare_results = @lib_element.compare_short_names(@form_element, params[:replacements])
      if @compare_results.any?(&:collision)
        render(:template => 'forms/fix_library_copy')
      else
        @form_element.copy_from_library(@lib_element, params)
      end

      redis.delete_matched("views/events/*")
    rescue FormElement::IllegalCopyOperation, FormElement::InvalidFormStructure, ActiveRecord::RecordInvalid
      @rjs_errors = @form_element.errors
      flash[:error] = t("element_copy_failed")
      render(:template => 'rjs-error')
    else
      @form = Form.find(@form_element.form_id)
    end
  end

  def library_admin
    begin
      @library_elements = FormElement.library_roots
      @type = params[:type].blank? ? "question_element" : params[:type]
    rescue Exception => ex
      flash[:error] = t("open_library_failed")
      render :template => 'rjs-error'
    end
  end

end
