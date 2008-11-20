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

class ProductionAddAndEditDiseaseCodes < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      say "Update diseases with CDC values"
      
      aids = Disease.find_by_disease_name("AIDS")
      unless aids.nil?
        aids.cdc_code = "10560"
        aids.save!
      end

      amebiasis = Disease.find_by_disease_name("Amebiasis")
      unless amebiasis.nil?
        amebiasis.cdc_code = "11040"
        amebiasis.save!
      end
      
      anthrax = Disease.find_by_disease_name("Anthrax")
      unless anthrax.nil?
        anthrax.cdc_code = "10350"
        anthrax.save!
      end
      
      ma = Disease.find_by_disease_name("Meningitis, Aseptic")
      unless ma.nil?
        ma.cdc_code = "10010"
        ma.save!
      end
      
      mb = Disease.find_by_disease_name("Meningitis, bacterial other")
      unless mb.nil?
        mb.cdc_code = "10650"
        mb.save!
      end
      
      bru = Disease.find_by_disease_name("Brucellosis")
      unless bru.nil?
        bru.cdc_code = "10020"
        bru.save!
      end
      
      camp = Disease.find_by_disease_name("Campylobacteriosis")
      unless camp.nil?
        camp.cdc_code = "11020"
        camp.save!
      end
      
      chan = Disease.find_by_disease_name("Chancroid")
      unless chan.nil?
        chan.cdc_code = "10273"
        chan.save!
      end
      
      cry = Disease.find_by_disease_name("Cryptosporidiosis")
      unless cry.nil?
        cry.cdc_code = "11580"
        cry.save!
      end
      
      cyc = Disease.find_by_disease_name("Cyclosporiasis")
      unless cyc.nil?
        cyc.cdc_code = "11575"
        cyc.save!
      end
      
      den = Disease.find_by_disease_name("Dengue hemorrhagic fever")
      unless den.nil?
        den.cdc_code = "10685"
        den.save!
      end
      
      dip = Disease.find_by_disease_name("Diphtheria")
      unless dip.nil?
        dip.cdc_code = "10040"
        dip.save!
      end
      
      enc = Disease.find_by_disease_name("Encephalitis, post-mumps")
      unless enc.nil?
        enc.cdc_code = "10080"
        enc.save!
      end
      
      encp = Disease.find_by_disease_name("Encephalitis, primary")
      unless encp.nil?
        encp.cdc_code = "10050"
        encp.save!
      end
      
      encpo = Disease.find_by_disease_name("Encephalitis, post-other")
      unless encpo.nil?
        encpo.cdc_code = "10090"
        encpo.save!
      end
      
      hepa = Disease.find_by_disease_name("Hepatitis A")
      unless hepa.nil?
        hepa.cdc_code = "10110"
        hepa.save!
      end
      
      hepbv = Disease.find_by_disease_name("Hepatitis B virus infection, chronic")
      unless hepbv.nil?
        hepbv.cdc_code = "10105"
        hepbv.save!
      end
      
      hepba = Disease.find_by_disease_name("Hepatitis B, acute")
      unless hepba.nil?
        hepba.cdc_code = "10100"
        hepba.save!
      end
      
      hepbvi = Disease.find_by_disease_name("Hepatitis B, virus infection perinatal")
      unless hepbvi.nil?
        hepbvi.cdc_code = "10104"
        hepbvi.save!
      end
      
      hepcv = Disease.find_by_disease_name("Hepatitis C virus infection, past or present")
      unless hepcv.nil?
        hepcv.cdc_code = "10106"
        hepcv.save!
      end
      
      hepca = Disease.find_by_disease_name("Hepatitis C, acute")
      unless hepca.nil?
        hepca.cdc_code = "10101"
        hepca.save!
      end
      
      hepd = Disease.find_by_disease_name("Hepatitis Delta co- or super-infection, acute (Hepatitis D)")
      unless hepd.nil?
        hepd.cdc_code = "10102"
        hepd.save!
      end
      
      hepe = Disease.find_by_disease_name("Hepatitis E, acute")
      unless hepe.nil?
        hepe.cdc_code = "10103"
        hepe.save!
      end
      
      hepvo = Disease.find_by_disease_name("Hepatitis, viral other")
      unless hepvo.nil?
        hepvo.cdc_code = "10120"
        hepvo.save!
      end
      
      lp = Disease.find_by_disease_name("Z -Lead poisoning")
      unless lp.nil?
        lp.cdc_code = "32010"
        lp.save!
      end
      
      leg = Disease.find_by_disease_name("Legionellosis")
      unless leg.nil?
        leg.cdc_code = "10490"
        leg.save!
      end

      mal = Disease.find_by_disease_name("Malaria")
      unless mal.nil?
        mal.cdc_code = "10130"
        mal.save!
      end
      
      mump = Disease.find_by_disease_name("Mumps")
      unless mump.nil?
        mump.cdc_code = "10180"
        mump.save!
      end
      
      syp = Disease.find_by_disease_name("Syphilis, neurosyphilis")
      unless syp.nil?
        syp.cdc_code = "10317"
        syp.save!
      end
      
      pert = Disease.find_by_disease_name("Pertussis")
      unless pert.nil?
        pert.cdc_code = "10190"
        pert.save!
      end
      
      pla = Disease.find_by_disease_name("Plague")
      unless pla.nil?
        pla.cdc_code = "10440"
        pla.save!
      end
      
      q = Disease.find_by_disease_name("Q fever")
      unless q.nil?
        q.cdc_code = "10255"
        q.save!
      end
      
      rub = Disease.find_by_disease_name("Rubella")
      unless rub.nil?
        rub.cdc_code = "10200"
        rub.save!
      end
      
      pox = Disease.find_by_disease_name("Smallpox")
      unless pox.nil?
        pox.cdc_code = "11800"
        pox.save!
      end
      
      tet = Disease.find_by_disease_name("Tetanus")
      unless tet.nil?
        tet.cdc_code = "10210"
        tet.save!
      end
      
      tula = Disease.find_by_disease_name("Tularemia")
      unless tula.nil?
        tula.cdc_code = "10230"
        tula.save!
      end

      menin = Disease.find_by_disease_name("Meningococcal disease (Neisseria meningitidis)")
      unless menin.nil?
        menin.cdc_code = "10150"
        menin.save!
      end

      hae = Disease.find_by_disease_name("Haemophilus influenzae, invasive disease")
      unless hae.nil?
        hae.cdc_code = "10590"
        hae.save!
      end
      
      list = Disease.find_by_disease_name("Listeriosis")
      unless list.nil?
        list.cdc_code = "10640"
        list.save!
      end

      lyme = Disease.find_by_disease_name("Lyme disease")
      unless lyme.nil?
        lyme.cdc_code = "11080"
        lyme.save!
      end

      meas = Disease.find_by_disease_name("Measles (rubeola)")
      unless meas.nil?
        meas.cdc_code = "10140"
        meas.save!
      end
      
      ### STDs ###
      
      chl = Disease.find_by_disease_name("Chlamydia trachomatis infection")
      unless chl.nil?
        chl.cdc_code = "10274"
        chl.save!
      end
      
      sypp = Disease.find_by_disease_name("Syphilis, primary")
      unless sypp.nil?
        sypp.cdc_code = "10311"
        sypp.save!
      end

      syps = Disease.find_by_disease_name("Syphilis, secondary")
      unless syps.nil?
        syps.cdc_code = "10312"
        syps.save!
      end

      sypel = Disease.find_by_disease_name("Syphilis, early latent")
      unless sypel.nil?
        sypel.cdc_code = "10313"
        sypel.save!
      end

      sypll = Disease.find_by_disease_name("Syphilis, late latent")
      unless sypll.nil?
        sypll.cdc_code = "10314"
        sypll.save!
      end
      
      sypul = Disease.find_by_disease_name("Syphilis, unknown latent")
      unless sypul.nil?
        sypul.cdc_code = "10315"
        sypul.save!
      end

      sypc = Disease.find_by_disease_name("Syphilis, congenital")
      unless sypc.nil?
        sypc.cdc_code = "10316"
        sypc.save!
      end
      
      sypmal = Disease.find_by_disease_name("Syphilis, late with clinical manifestations other than neurosyphilis")
      unless sypmal.nil?
        sypmal.cdc_code = "10318"
        sypmal.save!
      end
      
      gono = Disease.find_by_disease_name("Gonorrhea")
      unless gono.nil?
        gono.cdc_code = "10280"
        gono.save!
      end

      lgv = Disease.find_by_disease_name("Lymphogranuloma venereum (LGV)")
      unless lgv.nil?
        lgv.cdc_code = "10306"
        lgv.save!
      end
      
      pid = Disease.find_by_disease_name("Pelvic Inflammatory Disease (PID)")
      unless pid.nil?
        pid.cdc_code = "10309"
        pid.save!
      end
     
    end
  end

  def self.down
  end
end
