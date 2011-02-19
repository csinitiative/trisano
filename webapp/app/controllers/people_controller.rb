# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class PeopleController < ApplicationController

  def index
    unless User.current_user.is_entitled_to?(:manage_entities)
      render :partial => "people/permission_denied", :locals => { :reason => t("no_people_management_privs") }, :layout => true, :status => 403 and return
    end

    return unless index_processing

    respond_to do |format|
      format.html
      format.xml  { render :xml => @people }
      format.csv
    end
  end

  def show
    @person = PersonEntity.find(params[:id])

    unless User.current_user.is_entitled_to?(:manage_entities)
      render :partial => "people/permission_denied", :locals => { :reason => t("no_people_management_privs"), :person => @person }, :layout => true, :status => 403 and return
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @person }
    end
  end

  def new
    @person = PersonEntity.new
    @person.person = Person.new
    @person.canonical_address = Address.new
    @person.telephones << Telephone.new
    @person.email_addresses << EmailAddress.new

    unless User.current_user.is_entitled_to?(:manage_entities)
      render :partial => "people/permission_denied", :locals => { :reason => t("no_people_management_privs"), :person => @person }, :layout => true, :status => 403 and return
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @person }
    end
  end

  def edit
    @person = PersonEntity.find(params[:id])

    if @person.canonical_address.nil?
      @person.canonical_address = Address.new
    end

    if @person.telephones.empty?
      @person.telephones << Telephone.new
    end

    if @person.email_addresses.empty?
      @person.email_addresses << EmailAddress.new
    end

    unless User.current_user.is_entitled_to?(:manage_entities)
      render :partial => "people/permission_denied", :locals => { :reason => t("no_people_management_privs"), :person => @person }, :layout => true, :status => 403 and return
    end
  end

  def create
    go_back = params.delete(:return)

    @person = PersonEntity.new
    @person.person = Person.new
    @person.update_attributes(params[:person_entity])

    unless User.current_user.is_entitled_to?(:manage_entities)
      render :partial => "people/permission_denied", :locals => { :reason => t("no_people_management_privs"), :person => @person }, :layout => true, :status => 403 and return
    end

    respond_to do |format|
      if @person.save
        flash[:notice] = t("person_created")
        format.html {
          if go_back
            redirect_to(edit_person_url(@person))
          else
            redirect_to(person_url(@person))
          end
        }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        @person.canonical_address = Address.new
        @person.telephones << Telephone.new
        @person.email_addresses << EmailAddress.new
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    go_back = params.delete(:return)

    @person = PersonEntity.find(params[:id])

    unless User.current_user.is_entitled_to?(:manage_entities)
      render :partial => "people/permission_denied", :locals => { :reason => t("no_people_management_privs"), :person => @person }, :layout => true, :status => 403 and return
    end

    respond_to do |format|
      if @person.update_attributes(params[:person_entity])
        flash[:notice] = t("person_updated")
        format.html {
          if go_back
            redirect_to(edit_person_url(@person))
          else
            redirect_to(person_url(@person))
          end
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    head :method_not_allowed
  end

  private

  def index_processing
    if params[:per_page].to_i > 100
      render :text => t("too_many_people"), :layout => 'application', :status => 400
      return false
    end

    begin
      @export_options = params[:export_options]

      @people = Person.find_all_for_filtered_view(:first_name => params[:first_name],
                                                  :last_name => params[:last_name],
                                                  :birth_date => params[:birth_date],
                                                  :person_type => params[:person_type],
                                                  :order_by => params[:sort_order].try(:clone),
                                                  :use_starts_with_search => params[:use_starts_with_search],
                                                  :page => params[:page],
                                                  :include => [:person_entity],
                                                  :per_page => params[:per_page],
                                                  :excluding => params[:excluding])
    rescue
      render :file => static_error_page_path(404), :layout => 'application', :status => 404
      return false
    end
    return true
  end

end
