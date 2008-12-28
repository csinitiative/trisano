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
class CdcExport < ActiveRecord::Base

  class << self
    def weekly_cdc_export(mmwr_week)


      HERE (passing in mmwr_week.  Need to worry about week one's previous mmwr week AND YEAR)


      where = %Q|(("mmwr_week"=#{mmwr_week} OR "mmwr_week"=#{mmwr_week - 1}) AND "mmwr_year"=#{this_mmwr_year})|
      where << " OR (cdc_updated_at BETWEEN '#{Mmwr.new(Date.today - 7).mmwr_week_range.start_date}' AND '#{Mmwr.new.mmwr_week_range.end_date}')"
      # The following issues 133 separate selects to generate the where clause component.  What's it doing?
      where << (Disease.disease_status_where_clause || "")
      where << " AND exp_deleted_at IS NULL"

      events = ActiveRecord::Base.connection.select_all("select * from v_export_cdc where (#{where})")
      events.map!{ |event| event.extend(Export::Cdc::Record) }     
      events
    end

    def weekly_cdc_deletes(mmwr_week)
      where = ['(cdc_updated_at IS NOT NULL) AND ((exp_deleted_at IS NOT NULL)']      
      diseases = Disease.with_no_export_status
      unless  diseases.empty?
        unless  diseases.empty?
          where << "OR (disease_id IN (#{diseases.collect(&:id).join(',')}))"
        end
        invalid_case_status = Disease.with_invalid_case_status_clause
        unless invalid_case_status.blank?
          where << "OR #{invalid_case_status}"
        end
      end      
      where << ")"
      events = ActiveRecord::Base.connection.select_all("select * from v_export_cdc where (#{where.join(' ')})")
      events.map!{ |event| event.extend(Export::Cdc::DeleteRecord) }
      events
    end

    def verification_records
      where = "where exp_year='#{this_mmwr_year.to_s[2..3]}' AND exp_deleted_at IS NULL"
      disease_status_clause = Disease.disease_status_where_clause
      where << " AND #{disease_status_clause}" unless disease_status_clause.blank?
      group_by = "GROUP BY exp_event, exp_state, exp_year"
      select = "SELECT COUNT(*), exp_event, exp_state, exp_year FROM v_export_cdc"
      records = ActiveRecord::Base.connection.select_all("#{select} #{where} #{group_by}")
      records.map!{|record| record.extend(Export::Cdc::VerificationRecord)}
      records
    end

    private

    def this_mmwr_week
      mmwr = Mmwr.new
      mmwr.mmwr_week
    end

    def last_mmwr_week
      mmwr = Mmwr.new(Date.today - 7)
      mmwr.mmwr_week
    end

    def this_mmwr_year
      mmwr = Mmwr.new
      mmwr.mmwr_year
    end

  end
end
