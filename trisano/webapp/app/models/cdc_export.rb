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
    def weekly_cdc_export(start_mmwr, end_mmwr)
      raise ArgumentError unless start_mmwr.is_a?(Mmwr) && end_mmwr.is_a?(Mmwr)
      where = []
      where << <<-END_WHERE_CLAUSE
        (
          ((mmwr_week=#{start_mmwr.mmwr_week} AND mmwr_year=#{start_mmwr.mmwr_year}) OR (mmwr_week=#{end_mmwr.mmwr_week} AND mmwr_year=#{end_mmwr.mmwr_year}))
          OR
          (cdc_updated_at BETWEEN '#{start_mmwr.mmwr_week_range.start_date}' AND '#{end_mmwr.mmwr_week_range.end_date}')
        )
      END_WHERE_CLAUSE
      # The following issues 133 separate selects to generate the where clause component.  What's it doing?
      where << Disease.disease_status_where_clause
      where << "exp_deleted_at IS NULL"

      events = ActiveRecord::Base.connection.select_all("select * from v_export_cdc where (#{where.compact.join(' AND ')})")
      events.map!{ |event| event.extend(Export::Cdc::Record) }     
      events
    end

    def annual_cdc_export(mmwr_year)
      where = []
      where << "mmwr_year='#{mmwr_year}'"
      # The following issues 133 separate selects to generate the where clause component.  What's it doing?
      where << Disease.disease_status_where_clause
      where << "exp_deleted_at IS NULL"

      events = ActiveRecord::Base.connection.select_all("select * from v_export_cdc where (#{where.compact.join(' AND ')})")
      events.map!{ |event| event.extend(Export::Cdc::Record) }     
      events
    end

    def cdc_deletes(start_mmwr, end_mmwr)
      where = [ "sent_to_cdc=true AND ((exp_deleted_at BETWEEN '#{start_mmwr.mmwr_week_range.start_date}' AND '#{end_mmwr.mmwr_week_range.end_date}')" ]
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

    # set sent to true for all cdc records
    def reset_sent_status(cdc_records)
      event_ids = cdc_records.compact.collect {|record| record.event_id}
      Event.update_all('sent_to_cdc=true', ['id IN (?)', event_ids])
    end

    private

    def this_mmwr_year
      mmwr = Mmwr.new
      mmwr.mmwr_year
    end

  end
end
