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

class CdcEventsController < AdminController

  def index
  end

  def current_week
    start_mmwr = Mmwr.new(Date.today - 7)
    end_mmwr = Mmwr.new

    @events = weekly_events(start_mmwr, end_mmwr)
    CdcExport.reset_sent_status(@events)

    respond_to do |format|
      format.dat {
        begin 
          render :template => "cdc_events/format", :layout => false
        rescue
          I18nLogger.error("logger.cdc_export_error")
          DEFAULT_LOGGER.error($!)
          if RAILS_ENV == "production"
            error_msg = t("cdc_export_error", :message => $!.message)
          else
            error_msg = $!
          end
          render :text => error_msg
        else
          headers['Content-Disposition'] = "Attachment; filename=\"cdc_export_mmwr_weeks_#{start_mmwr.mmwr_week}-#{end_mmwr.mmwr_week}.dat\""
        end
      }
      # For testing purposes only.  Keeps the file save dialog from popping up
      format.txt {
        render :template => "cdc_events/format.dat.haml", :layout => false
      }
    end
  end

  def by_range
    begin
      start_mmwr = Mmwr.new(Date.parse(params[:start_date]))
      end_mmwr = Mmwr.new(Date.parse(params[:end_date]))
    rescue
      flash[:error] = t("invalid_date_format")
      redirect_to cdc_events_path
      return
    end

    # CDC reports cannot span MMWR years.  If the entered dates cause this to happen, reset the start dates to MMWR week 1 of the end date's year
    # Use January 4th to guarantee you end up in week 1 and not week 52 or 53 of the prior year.
    if start_mmwr.mmwr_year != end_mmwr.mmwr_year
      start_mmwr = Mmwr.new(Date.parse("#{end_mmwr.mmwr_year}-01-04"))
    end

    @events = weekly_events(start_mmwr, end_mmwr)
    CdcExport.reset_sent_status(@events)
    respond_to do |format|
      format.dat {
        begin
          render :template => "cdc_events/format", :layout => false
        rescue
          I18nLogger.error("logger.cdc_export_error")
          DEFAULT_LOGGER.error($!)
          if RAILS_ENV == "production"
            error_msg = t("cdc_export_error", :message => $!.message)
          else
            error_msg = $!
          end
          render :text => error_msg
        else
          headers['Content-Disposition'] = "Attachment; filename=\"cdc_export_mmwr_weeks_#{start_mmwr.mmwr_week}-#{end_mmwr.mmwr_week}.dat\""
        end
      }
    end
  end

  def current_ytd
    mmwr_year = params[:mmwr_year] || Mmwr.new.mmwr_year
    @events = []
    @events << CdcExport.verification_records(mmwr_year)
    @events << CdcExport.annual_cdc_export(mmwr_year)
    @events.flatten!
    CdcExport.reset_sent_status(@events)
    respond_to do |format|
      format.dat {
        begin
          render :template => "cdc_events/format", :layout => false
        rescue
          DEFAULT_LOGGER.error($!)
          if RAILS_ENV == "production"
            error_msg = t("cdc_export_error", :message => $!.message)
          else
            error_msg = $!
          end
          render :text => error_msg
        else
          headers['Content-Disposition'] = "Attachment; filename=\"cdc_export_mmwr_year#{mmwr_year}.dat\""
        end
      }
    end
  end

  def show
    head :method_not_allowed
  end

  def new
    head :method_not_allowed
  end

  def edit
    head :method_not_allowed
  end

  def create
    head :method_not_allowed
  end

  def update
    head :method_not_allowed
  end

  def delete
    head :method_not_allowed
  end

  private

  def weekly_events(start_mmwr, end_mmwr)
    events = []
    events << CdcExport.verification_records(end_mmwr.mmwr_year, end_mmwr.mmwr_week)
    events << CdcExport.weekly_cdc_export(start_mmwr, end_mmwr)
    events << CdcExport.cdc_deletes(start_mmwr, end_mmwr)
    events.flatten!
  end
end
