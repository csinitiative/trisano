# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

describe LoincCode do
  fixtures :external_codes, :loinc_codes

  before do
    @scale = external_codes :loinc_scale_ord
  end

  it "should produce an error is a loinc code not in expected format" do
    LoincCode.create(:loinc_code => 'xxx-1').errors.on(:loinc_code).should == "is invalid (should be nnnnn-n)"
  end

  it 'loinc_code value should be present' do
    LoincCode.create(:loinc_code => '').errors.on(:loinc_code).should == "can't be blank"
  end

  it 'scale_id should be present' do
    LoincCode.create(:scale_id => '').errors.on(:scale_id).should == "can't be blank"
  end

  it 'by default, should return all lists in loinc code numerical order' do
    loinc = LoincCode.create! :loinc_code => '11234-1', :scale_id => @scale.id
    loinc.clone.update_attributes! :loinc_code => '114-9'
    LoincCode.find(:all).collect(&:loinc_code).should == ["114-9", "5221-7", "10000-1", "11234-1", "13954-3"]
  end

  describe 'loinc code' do

    it 'should be unique' do
      LoincCode.create :loinc_code => '999999-9', :scale_id => @scale.id
      LoincCode.create(:loinc_code => '999999-9').errors.on(:loinc_code).should == "has already been taken"
      LoincCode.create(:loinc_code => '888888-8').errors.on(:loinc_code).should be_nil
    end

    it 'should not be longer then 10 chars' do
      LoincCode.create(:loinc_code => '999999999-9').errors.on(:loinc_code).should == "is too long (maximum is 10 characters)"
      LoincCode.create(:loinc_code => '99999999-9' ).errors.on(:loinc_code).should be_nil
    end

    it 'should be left and right trimmed' do
      loinc = LoincCode.create(:loinc_code => '99999-9 ')
      loinc.errors.on(:loinc_code).should be_nil
      loinc.loinc_code.should == '99999-9'
    end

  end

  describe 'test name' do

    it 'should not be longer then 255 chars' do
      LoincCode.create(:loinc_code => '999999-9', :test_name => ('c' * 256)).errors.on(:test_name).should == "is too long (maximum is 255 characters)"
      LoincCode.create(:loinc_code => '999999-9', :test_name => ('c' * 255)).errors.on(:test_name).should be_nil
    end

  end

  describe '#search_unrelated_loincs' do

    before do
      @loinc_code = LoincCode.create!(:loinc_code => '14375-1',
                                      :test_name => 'Nulla felis nibh, aliquet eget, Unspecified',
                                      :scale_id => external_codes(:loinc_scale_ord).id)
      @common_test_type = CommonTestType.create! :common_name => 'Nulla felis nibh, aliquet eget.'
    end

    it 'should find all matches, if none are associated with this instance' do
      LoincCode.search_unrelated_loincs(@common_test_type, :test_name => 'nulla').should == [@loinc_code]
    end

    it 'should return empty array if all matches are already assoc, with this instance' do
      @common_test_type.update_loinc_code_ids :add => [@loinc_code.id]
      LoincCode.search_unrelated_loincs(@common_test_type, :test_name => 'nulla').should == []
    end

    it 'should return empty array if no search criteria provided' do
      LoincCode.search_unrelated_loincs(@common_test_type).should == []
    end

  end

  describe 'associations' do

    it { should belong_to(:common_test_type) }
    it { should have_many(:disease_common_test_types) }
    it { should have_many(:diseases) }

  end

  describe "loading from csv" do
    fixtures :external_codes

    it 'should bulk load from loinctab data' do
      lambda do
        LoincCode.load_from_loinctab <<LOINCTAB
"LOINC_NUM"	"COMPONENT"	"PROPERTY"	"TIME_ASPCT"	"SYSTEM"	"SCALE_TYP"	"METHOD_TYP"	"RELAT_NMS"	"CLASS"	"SOURCE"	"DT_LAST_CH"	"CHNG_TYPE"	"COMMENTS"	"ANSWERLIST"	"STATUS"	"MAP_TO"	"SCOPE"	"CONSUMER_NAME"	"IPCC_UNITS"	"REFERENCE"	"EXACT_CMP_SY"	"MOLAR_MASS"	"CLASSTYPE"	"FORMULA"	"SPECIES"	"EXMPL_ANSWERS"	"ACSSYM"	"BASE_NAME"	"FINAL"	"NAACCR_ID"	"CODE_TABLE"	"SETROOT"	"PANELELEMENTS"	"SURVEY_QUEST_TEXT"	"SURVEY_QUEST_SRC"	"UNITSREQUIRED"	"SUBMITTED_UNITS"	"RELATEDNAMES2"	"SHORTNAME"	"ORDER_OBS"	"CDISC_COMMON_TESTS"	"HL7_FIELD_SUBFIELD_ID"	"EXTERNAL_COPYRIGHT_NOTICE"	"EXAMPLE_UNITS"	"INPC_PERCENTAGE"	"LONG_COMMON_NAME"	"HL7_V2_DATATYPE"	"HL7_V3_DATATYPE"	"CURATED_RANGE_AND_UNITS"	"DEFINITION_DESCRIPTION_HELP"
"10674-0"	"Hepatitis B virus surface Ag"	"ACnc"	"Pt"	"Tiss"	"Ord"	"Immune stain"	"HEP B;HEPATITIS TYPE B;HBV"	"MICRO"	"DL-R"	"19980318"	"NAM"											1						"Y"			0						"Australia antigen; HBsAG; HBV surface; Hep Bs; HBs; HepB; Hep B; Arbitrary concentration; Point in time; Random; Tissue; Ql; Ordinal; QL; Qualitative; Qual; Screen; ImStn; Immunostain; Immunohistochemical stain; IHC; Antigen; Antigens; Imun; Imune; Imm; Surf; Hepatit; Hepatis; Microbiology"	"HBV surface Ag Tiss Ql ImStn"	"Both"					0	"Hepatitis B virus surface Ag [Presence] in Tissue by Immune stain"				
"11486-8"	"Chemotherapy records"	"Find"	"-"	"^Patient"	"Doc"			"ATTACH.CLINRPT"	"CJM"	"20080404"	"MIN"											3						"Y"			0						"Finding; Findings"							0	"Chemotherapy records"	"TX/ED"			
"10675-7"	"Hepatitis B virus surface Ag"	"Prid"	"Pt"	"Tiss"	"Nom"	"Orcein stain"	"HEP B;HEPATITIS TYPE B;HBV;SHIKATA"	"MICRO"	"DL-R"	"19980318"	"NAM"											1						"Y"			0						"Australia antigen; HBsAG; HBV surface; Hep Bs; HBs; HepB; Hep B; Identity or presence; Point in time; Random; Tissue; Nominal; Orcein Stn; Shikata technique; Antigen; Antigens; Surf; Hepatit; Hepatis; Microbiology"	"HBV surface Ag Tiss Orcein Stn"	"Both"					0	"Hepatitis B virus surface Ag [Identifier] in Tissue by Orcein stain"				
"10676-5"	"Hepatitis C virus RNA"	"ACnc"	"Pt"	"Ser/Plas"	"Qn"	"Probe.amp"	"HEP C;HEPATITIS TYPE C;HCV"	"MICRO"	"OMH"	"20040316"	"MAJ"											1						"Y"			0				"Y"		"Ribonucleic acid; HCV; Hep C; Arbitrary concentration; Point in time; Random; SerPl; SerPlas; SerP; Serum; SR; Plasma; Pl; Plsm; Quantitative; QNT; Quant; Quan; Amp Prb; Probe with ampification; DNA probe; Amplif; Amplification; Amplified; Hepatit; Hepatis; Microbiology"	"HCV RNA SerPl Amp Prb-aCnc"	"Both"					0	"Hepatitis C virus RNA [Units/volume] (viral load) in Serum or Plasma by Probe with amplification"				
"101-6"	"Cefoperazone"	"Susc"	"Pt"	"Isolate"	"OrdQn"	"Agar diffusion"	"CEFOBID;KIRBY-BAUER"	"ABXBACT"	"SH"	"20061026"	"MAJ"											1						"Y"			0						"Cefobid; Susceptibility; Susceptibilty; Sus; Suscept; Susceptibilities; Point in time; Random; Islt; Isol; KB; Kirby-bauer; Disk diffusion; ANTIBIOTIC SUSCEPTIBILITIES"	"Cefoperazone Islt KB"	"Observation"					0	"Cefoperazone [Susceptibility] by Disk diffusion (KB)"				
LOINCTAB
      end.should change(LoincCode, :count).by(4)
    end
  end
end
