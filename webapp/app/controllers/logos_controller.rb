
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

class LogosController < ApplicationController

  before_filter :check_role, :except => [:show]

  def new
    @logo = Logo.new
  end

  def create

    # This uploaded file switch to base64 is here due to issues saving files
    # to PostgreSQL 9.1 where it sometimes has an error around invalid UTF8 characters.
    logo = params[:logo]["uploaded_data"]
    logo_path = logo.path

    content_type = logo.content_type
    original_filename = logo.original_filename

    data_b64 = Base64.encode64(logo.read)
    File.open(logo_path + ".base64", "w") {|f| f.write data_b64}

    logo_b64 = File.open(logo_path + ".base64", "r")

    def logo_b64.size
      File.size(self.path)
    end

    logo_b64.metaclass.send(:define_method, 'content_type') do
      content_type
    end

    logo_b64.metaclass.send(:define_method, 'original_filename') do
      original_filename
    end

    params[:logo]["uploaded_data"] = logo_b64


    @logo = Logo.new(params[:logo])

    if @logo.save
      flash[:notice] = t("logo_created")
    end

    redirect_to new_logo_url
  end

  def show
    logo = Logo.find(params[:id])

    send_data(Base64.decode64(logo.current_data),
      :type  => logo.content_type,
      :filename => logo.filename)
  rescue
    render :file => static_error_page_path(404), :layout => 'application', :status => 404 and return
  end

  def delete

    begin
      Logo.delete_all
    rescue Exception => ex
      logger.debug ex
      flash[:error] = ex.message
    end

    redirect_to new_logo_url
  end

  protected

  def check_role
    unless access_granted?
      I18nLogger.info("logger.unauthorized_admin_access_by", :uid => User.current_user.uid)
      render :partial => "events/permission_denied", :locals => { :reason => t("no_admin_rights"), :event => nil }, :layout => true, :status => 403 and return
    end
  end

  def access_granted?
    User.current_user.is_admin?
  end

end
