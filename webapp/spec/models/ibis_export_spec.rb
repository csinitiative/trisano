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
require File.dirname(__FILE__) + '/../spec_helper'

describe IbisExport do
  context "IBIS exports" do
    let(:event) do
      Factory.create(:morbidity_event_with_disease, {
        :first_reported_PH_date => Date.parse("2009-11-29"),
        :created_at => DateTime.parse("2009-11-30 13:30")
      })
    end

    describe "includes records" do
      it "created on the first day of the date range" do
        IbisExport.exportable_ibis_records("2009-11-30", "2009-12-1").should be_empty
        event.reload
        results = IbisExport.exportable_ibis_records("2009-11-30", "2009-12-1")
        results.map(&:record_number).should == [event.record_number]
      end

      it "created on the last day of the date range" do
        IbisExport.exportable_ibis_records("2009-11-29", "2009-11-30").should be_empty
        event.reload
        results = IbisExport.exportable_ibis_records("2009-11-29", "2009-11-30")
        results.map(&:record_number).should == [event.record_number]
      end

      it "created between the start and end dates" do
        IbisExport.exportable_ibis_records("2009-11-15", "2009-12-15").should be_empty
        event.reload
        results = IbisExport.exportable_ibis_records("2009-11-15", "2009-12-15")
        results.map(&:record_number).should == [event.record_number]
      end

      it "ibis updated on the first day of the date range" do
        IbisExport.exportable_ibis_records("2009-12-15", "2009-12-16").should be_empty
        event.update_attributes!(:ibis_updated_at => '2009-12-15')
        event.reload
        results = IbisExport.exportable_ibis_records("2009-12-15", "2009-12-16")
        results.map(&:record_number).should == [event.record_number]
      end

      it "ibis updated on the last day of the date range" do
        IbisExport.exportable_ibis_records("2009-12-14", "2009-12-15").should be_empty
        event.update_attributes!(:ibis_updated_at => '2009-12-15')
        event.reload
        results = IbisExport.exportable_ibis_records("2009-12-14", "2009-12-15")
        results.map(&:record_number).should == [event.record_number]
      end

      it "ibis updated between the start and end dates" do
        IbisExport.exportable_ibis_records("2009-12-01", "2009-12-31").should be_empty
        event.update_attributes!(:ibis_updated_at => '2009-12-15')
        event.reload
        results = IbisExport.exportable_ibis_records("2009-12-01", "2009-12-31")
        results.map(&:record_number).should == [event.record_number]
      end

      describe "sent to ibis, and then later deleted" do
        it "if deleted on the first day of the date range" do
          IbisExport.exportable_ibis_records("2009-12-15", "2009-12-16").should == []
          event.update_attributes!(:sent_to_ibis => true, :deleted_at => "2009-12-15 15:00")
          event.reload
          results = IbisExport.exportable_ibis_records("2009-12-15", "2009-12-16")
          results.map(&:record_number).should == [event.record_number]
        end

        it "if deleted on the last day of the date range" do
          IbisExport.exportable_ibis_records("2009-12-14", "2009-12-15").should == []
          event.reload
          event.update_attributes!(:sent_to_ibis => true, :deleted_at => "2009-12-15 15:00")
          results = IbisExport.exportable_ibis_records("2009-12-14", "2009-12-15")
          results.map(&:record_number).should == [event.record_number]
        end

        it "if deleted between the date ranges" do
          IbisExport.exportable_ibis_records("2009-12-01", "2009-12-31").should == []
          event.reload
          event.update_attributes!(:sent_to_ibis => true, :deleted_at => "2009-12-15 15:00")
          results = IbisExport.exportable_ibis_records("2009-12-01", "2009-12-31")
          results.map(&:record_number).should == [event.record_number]
        end
      end
    end

    describe "excludes records" do
      it "if they don't have a disease" do
        event.disease_event.update_attributes!(:disease => nil)
        IbisExport.exportable_ibis_records("2009-11-29", "2009-11-30").should == []
      end

      it "if they are deleted" do
        event.update_attributes!(:deleted_at => DateTime.parse("2009-11-30 15:00"))
        IbisExport.exportable_ibis_records("2009-11-29", "2009-11-30").should == []
      end
    end
  end

end