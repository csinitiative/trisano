
# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

class ManagedContentsController < ApplicationController

  before_filter :check_role

  def edit
    @managed_content = ManagedContents.find(params[:id])
  end

  def update
    @managed_content = ManagedContents.find params[:id]

    respond_to do |format|
      if @managed_content.update_attributes params[:managed_contents]
        flash[:notice] = t("custom_footer_updated")
        format.html { redirect_to edit_managed_content_path(@managed_content) }
      else
        flash[:error] = t("could_not_complete_request")
        format.html { render :action => 'edit' }
      end
    end
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
