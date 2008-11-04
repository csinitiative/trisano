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
    def weekly_cdc_export
      where = [%Q|cdc_update=true AND (("mmwr_week"=#{this_mmwr_week} OR "mmwr_week"=#{last_mmwr_week}) AND "mmwr_year"=#{this_mmwr_year})|]
      where << Disease.disease_status_where_clause
      events = ActiveRecord::Base.connection.select_all("select * from v_export_cdc where (#{where.compact.join(' AND ')})")
      events.map!{ |event| event.extend(Export::Cdc::Record) }     
      events
    end

    def weekly_cdc_deletes
      where = ['(cdc_update=true AND sent_to_cdc=true)']      
      diseases = Disease.with_no_export_status
      unless  diseases.empty?
        where << "AND ("
        unless  diseases.empty?
          where << "(disease_id IN (#{diseases.collect(&:id).join(',')}))"
        end
        invalid_case_status = Disease.with_invalid_case_status_clause
        unless invalid_case_status.blank?
          where << "OR #{ invalid_case_status}"
        end
        where << ")"
      end
      events = ActiveRecord::Base.connection.select_all("select * from v_export_cdc where (#{where.join(' ')})")
      events.map!{ |event| event.extend(Export::Cdc::DeleteRecord) }
      events
    end

    def verification_records
      where = "where exp_year='#{this_mmwr_year.to_s[2..3]}'"
      disease_status_clause = Disease.disease_status_where_clause
      where << " AND #{disease_status_clause}" unless disease_status_clause.blank?
      group_by = "GROUP BY exp_event, exp_state, exp_year"
      select = "SELECT COUNT(*), exp_event, exp_state, exp_year FROM v_export_cdc"
      records = ActiveRecord::Base.connection.select_all("#{select} #{where} #{group_by}")
      records.map!{|record| record.extend(Export::Cdc::VerificationRecord)}
      records
    end

    # set updated to false and sent to true for all cdc records
    def reset_sent_status(cdc_records)
      event_ids = cdc_records.compact.collect {|record| record.event_id}
      Event.update_all('cdc_update=false, sent_to_cdc=true', ['id IN (?)', event_ids])
    end

    private

    def this_mmwr_week
      mmwr = Mmwr.new
      mmwr.mmwr_week
    end

    def last_mmwr_week
      this_mmwr_week - 1
    end

    def this_mmwr_year
      mmwr = Mmwr.new
      mmwr.mmwr_year
    end

  end
end
