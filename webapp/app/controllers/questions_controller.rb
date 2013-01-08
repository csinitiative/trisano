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

class QuestionsController < AdminController
  before_filter :find_questions

  def edit
  end

  def show
  end

  def update
    respond_to do |format|
      if @questions.update(params[:questions])
        flash[:notice] = t("form_questions_successfully_updated")
        format.html { redirect_to form_questions_path(@form) }
      else
        format.html { render :action => :edit, :status => :bad_request }
      end
    end
  end

  private

  def find_questions
    @form = Form.find(params[:form_id])
    @master_form = @form.template
    @questions = Questions.from_form(@form)
  end

end
