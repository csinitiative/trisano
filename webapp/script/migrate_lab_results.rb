require 'set'

class LabMigrator

  def initialize
    @lab_result = nil

    @test_types = {}
    CommonTestType.all.each { |ctt| @test_types[ctt.common_name] = ctt.id }

    @organisms = {}
    Organism.all.each { |o| @organisms[o.organism_name] = o.id }

    # The ordering in the production database is the order we want for this hash.  That is, "Reactive" before "Non-Reactive"
    @test_result_map = ActiveSupport::OrderedHash.new
    ExternalCode.find_all_by_code_name('test_result', :order => 'id').each { |result| @test_result_map[result.code_description] = result.id }

    @unknown_organisms = Set.new

    @interpretations = {}
    @interpretations_map = {}
    ExternalCode.find_all_by_code_name('lab_interpretation').each do |i|
      @interpretations[i.id] = i.code_description
      case i.the_code
      when "INCONCLUSIVE"
        map_to_id = ExternalCode.find_by_code_name_and_the_code('test_result', "EQUIVOCAL").id
      when "OTHER"
        map_to_id = ExternalCode.find_by_code_name_and_the_code('test_result', "OTHER").id
      when "PROBABLE"
        map_to_id = ExternalCode.find_by_code_name_and_the_code('test_result', "PRESUMPTIVE").id
      when "POSITIVE"
        map_to_id = ExternalCode.find_by_code_name_and_the_code('test_result', "POSITIVE").id
      when "NEGATIVE"
        map_to_id = ExternalCode.find_by_code_name_and_the_code('test_result', "NEGATIVE").id
      when "PENDING"
        map_to_id = ExternalCode.find_by_code_name_and_the_code('test_status', "I").id
        @pending_id = i.id
      end
      @interpretations_map[i.id] = map_to_id
    end

    @map_data = [ 
      { "African Tick Bite Fever" => 
        [
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value" ] },
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value" ] }
        ]
      },
   
      { "Amebiasis" =>
        [
          { "ELISA" => [ "set_test_type('Antigen by EIA/ELISA')", "set_organism('Entamoeba histolytica')" ] },
          { "Smear" => [ "set_test_type('Microscopy')", "set_organism('Entamoeba histolytica')" ] }
        ]
      }, 

      { "Anthrax" =>
        [
          { "Culture" => [ "set_test_type('Culture')", "set_organism('Bacillus anthracis')" ] },
          { "PCR" => [ "set_test_type('PCR/amplification')", "set_organism('Bacillus anthracis')" ] }
        ]
      }, 

      { "Botulism" =>
        [
          { "Bioassay" => [ "set_test_type('Toxin assay')", "move_test_result_to_result_value", "set_organism('Clostridium botulinum')" ] },
          { "unknown" => [ "set_test_type('Toxin assay')", "move_test_result_to_result_value", "set_organism('Clostridium botulinum')" ] }
        ]
      },

      { "Brucellosis" =>
        [
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Brucella species')" ] },
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Brucella species')" ] },
          { "Culture" => [ "set_test_type('Culture')" ] },
          { "amplification" => [ "set_test_type('PCR/amplification')" ] },
          { "unknown" => [ "set_test_type('Unknown method')" ] }
        ]
      },

      { "Campylobacteriosis" =>
        [
          { "Culture" => [ "set_test_type('Culture')", "move_test_result_to_result_value", "campy_organism" ] },
          { "EIA/ELISA" => [ "set_test_type('Antigen by EIA/ELISA')", "set_organism('Campylobacter species')" ] },
          { "PFGE" => [ "set_test_type('PFGE')", "move_test_result_to_result_value" ] },
          { "typing" => [ "set_test_type('PFGE')", "move_test_result_to_result_value" ] },
          { "Serotype" => [ "set_test_type('PFGE')", "move_test_result_to_result_value" ] }
        ]
      },

      { "Chickenpox" =>
        [
          { "Culture" => [ "set_test_type('Culture')", "set_organism('Varicella-zoster virus')" ] },
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Varicella-zoster virus')" ] },
          { "PCR" => [ "set_test_type('PCR/amplification')", "set_organism('Varicella-zoster virus')" ] },
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Varicella-zoster virus')" ] },
          { "Smear" => [ "set_test_type('Antigen by DFA/IF')", "set_organism('Varicella-zoster virus')" ] }
        ]
      },

      { "Chlamydia trachomatis infection" =>
        [
          { "DNA" => [ "set_test_type('DNA probe - not amplified/PCR')", "set_organism('Chlamydia trachomatis')" ] },
          { "Antigen" => [ "set_test_type('Antigen, unknown method')", "set_organism('Chlamydia trachomatis')" ] },
          { "gen" => [ "set_test_type('DNA probe - not amplified/PCR')", "set_organism('Chlamydia trachomatis')" ] },
          { "Amp" => [ "set_test_type('PCR/amplification')", "set_organism('Chlamydia trachomatis')" ] },
          { "Aptim" => [ "set_test_type('PCR/amplification')", "set_organism('Chlamydia trachomatis')" ] },
          { "NAA" => [ "set_test_type('PCR/amplification')", "set_organism('Chlamydia trachomatis')" ] },
          { "RNA" => [ "set_test_type('PCR/amplification')", "set_organism('Chlamydia trachomatis')" ] },
          { "PCR" => [ "set_test_type('PCR/amplification')", "set_organism('Chlamydia trachomatis')" ] },
          { "SDA" => [ "set_test_type('PCR/amplification')", "set_organism('Chlamydia trachomatis')" ] },
          { "Culture" => [ "set_test_type('Culture')", "set_organism('Chlamydia trachomatis')" ] },
          { "IgG" => [ "set_test_type('IgG Antibody')", "set_organism('Chlamydia species')" ] },
          { "Serology" => [ "set_test_type('Total Antibody')", "move_test_result_to_result_value", "set_organism('Chlamydia species')" ] },
          { "=Ab" => [ "set_test_type('Total Antibody')", "move_test_result_to_result_value", "set_organism('Chlamydia species')" ] }
        ]
      },

      { "Cholera" =>
        [
          { "Culture" => [ "set_test_type('Culture')" ] }
        ]
      },

      { "Coccidioidomycosis" =>
        [
          { "=Serology - Total" => [ "set_test_type('Total Antibody')", "move_test_result_to_result_value", "set_organism('Coccidioides immitis')" ] },
          { "Culture" => [ "set_test_type('Culture')" ] },
          { "DNA" => [ "set_test_type('DNA probe - not amplified/PCR')", "set_test_result_from_lab_result_text", "set_organism('Coccidioides immitis')" ] },
          { "PCR" => [ "set_test_type('DNA probe - not amplified/PCR')", "move_test_result_to_result_value", "set_organism('Coccidioides immitis')" ] },
          { "Serology - IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Coccidioides immitis')" ] },
          { "Serology - IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Coccidioides immitis')" ] },
          { "EIA" => [ "set_ab_test_type()", "move_test_result_to_result_value", "set_organism('Coccidioides immitis')" ] },
          { "Smear" => [ "set_test_type('Microscopy')", "set_organism('Coccidioides species')" ] }
        ]
      },

      { "Colorado Tick Fever" =>
        [
          { "Culture" => [ "set_test_type('Culture')", "set_organism('Colorado tick fever virus')" ] }
        ]
      },

      { "Creutzfeldt-Jakob Disease" =>
        [
          { "PCR" => [ "set_test_type('PCR/amplification')" ] },
          { "Immunoassay" => [ "set_test_type('14-3-3 by EIA/ELISA')", "set_organism('Creutzfeldt-Jacob agent')" ] },
          { "Other" => [ "set_cjd_test_type", "move_test_result_to_result_value", "set_organism('Creutzfeldt-Jacob agent')" ] },
          { "EIA" => [ "set_cjd_test_type", "move_test_result_to_result_value", "set_organism('Creutzfeldt-Jacob agent')" ] }
        ]
      },

      { "Cryptosporidiosis" =>
        [
          { "Culture" => [ "set_test_type('Culture')" ] },
          { "EIA" => [ "set_test_type('Antigen by EIA/ELISA')", "set_organism('Cryptosporidium parvum')" ] }
        ]
      },

      { "Dengue" =>
        [
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Dengue virus')" ] },
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Dengue virus')" ] }
        ]
      },

      { "Encephalitis" =>
        [
          { "Culture" => [ "set_test_type('Culture')" ] },
          { "PCR" => [ "set_test_type('PCR/amplification')" ] },
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value" ] },
          { "Smear" => [ "set_test_type('Microscopy')" ] }
        ]
      },

      { "Giardiasis" =>
        [
          { "EIA" => [ "set_test_type('Antigen by EIA/ELISA')", "set_organism('Giardia species')" ] },
          { "smear" => [ "set_giardia_test_type", "set_organism('Giardia lamblia')" ] }
        ]
      },

      { "Gonorrhea" =>
        [
          { "DNA" => [ "set_test_type('DNA probe - not amplified/PCR')", "set_gonorrhea_organism" ] },
          { "Amp" => [ "set_test_type('PCR/amplification')", "set_gonorrhea_organism" ] },
          { "PCR" => [ "set_test_type('PCR/amplification')", "set_gonorrhea_organism" ] },
          { "NAA" => [ "set_test_type('PCR/amplification')", "set_gonorrhea_organism" ] },
          { "RNA" => [ "set_test_type('PCR/amplification')", "set_gonorrhea_organism" ] },
          { "gram" => [ "set_test_type('Microscopy')", "set_organism('Gram-negative diplococcus')" ] }
        ]
      },

      { "Haemophilus" =>
        [
          { "Culture" => [ "set_test_type('Culture')" ] },
          { "Typing" => [ "set_test_type('Culture')", "set_organism('Haemophilus influenzae')", "move_test_result_to_result_value" ] }
        ]
      },

      { "Hantavirus" =>
        [
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Hantavirus (sin nombre)')" ] },
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Hantavirus (sin nombre)')" ] }
        ]
      },

      { "Hepatitis A" =>
        [
          { "IgM" => [ "set_test_type('IgM Antibody')", "set_test_result_from_lab_result_text", "set_organism('Hepatitis A virus (human enterovirus 72)')" ] },
          { "Serology - Total" => [ "set_test_type('Total Antibody')", "set_test_result_from_lab_result_text", "set_organism('Hepatitis A virus (human enterovirus 72)')" ] }
        ]
      },
      { "Hepatitis B" =>
        [
          { "west" => [ "hep_b_west", "set_test_result_from_lab_result_text", "set_organism('Hepatitis B virus')" ] },
          { "eia" => [ "hep_b_eia", "set_test_result_from_lab_result_text", "set_organism('Hepatitis B virus')" ] },
          { "hbsag" => [ "hep_b_eia", "set_test_result_from_lab_result_text", "set_organism('Hepatitis B virus')" ] },
          { "pcr" => [ "set_test_type('PCR/amplification')", "set_organism('Hepatitis B virus')" ] },
          { "igm" => [ "set_test_type('IgM Antibody')", "set_test_result_from_lab_result_text", "set_organism('Hepatitis B virus')" ] }
        ]
      },

      { "Hepatitis C" =>
        [
          { "west" => [ "set_test_type('Western (immuno) blot')", "set_test_result_from_lab_result_text", "set_organism('Hepatitis C virus')" ] },
          { "riba" => [ "set_test_type('Western (immuno) blot')", "set_organism('Hepatitis C virus')" ] },
          { "antibody" => [ "hep_c_eia", "set_test_result_from_lab_result_text", "set_organism('Hepatitis C virus')" ] },
          { "eia" => [ "hep_c_eia", "set_test_result_from_lab_result_text", "set_organism('Hepatitis C virus')" ] },
          { "ab" => [ "hep_c_eia", "set_test_result_from_lab_result_text", "set_organism('Hepatitis C virus')" ] },
          { "pcr" => [ "set_test_type('PCR/amplification')", "move_test_result_to_result_value", "set_organism('Hepatitis C virus')" ] },
          { "typ" => [ "set_test_type('Genotype by PCR')", "move_test_result_to_result_value", "set_organism('Hepatitis C virus')" ] }
        ]
      },

      { "Influenza" =>
        [
          { "pcr" => [ "set_test_type('PCR/amplification')" ] },
          { "typing" => [ "set_test_type('PCR/amplification')" ] },
          { "culture" => [ "set_test_type('Culture')" ] },
          { "dfa" => [ "set_test_type('Antigen by DFA/IF')" ] },
          { "smear" => [ "set_test_type('Antigen by DFA/IF')" ] },
          { "eia" => [ "set_test_type('Rapid')" ] },
          { "rapid" => [ "set_test_type('Rapid')" ] },
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value" ] },
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value" ] }
        ]
      },

      { "Legionellosis" =>
        [
          { "culture" => [ "set_test_type('Culture')", "legionellosis_organism" ] },
          { "eia" => [ "set_test_type('Antigen by EIA/ELISA')", "set_organism('Legionella pneumophila serogroup 1')" ] },
          { "dfa" => [ "set_test_type('Antigen by DFA/IF')" ] },
          { "pcr" => [ "set_test_type('PCR/amplification')", "set_organism('Legionella pneumophila')" ] },
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Legionella pneumophila')" ] }
        ]
      },

      { "Listeriosis" =>
        [
          { "culture" => [ "set_test_type('Culture')", "set_organism('Listeria monocytogenes')" ] },
          { "DNA" => [ "set_test_type('DNA probe - not amplified/PCR')", "set_organism('Listeria monocytogenes')" ] },
          { "typing" => [ "set_test_type('PFGE')" ] }
        ]
      },

      { "Lyme disease" =>
        [
          { "ab" => [ "set_ab_test_type", "set_organism('Borrelia burgdorferi')" ] },
          { "west" => [ "set_lyme_test_type", "set_organism('Borrelia burgdorferi')" ] },
          { "smear" => [ "set_lyme_test_type", "set_organism('Borrelia burgdorferi')" ] },
          { "eia" => [ "lyme_eia", "move_test_result_to_result_value", "move_test_result_to_result_value", "set_organism('Borrelia burgdorferi')" ] },
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Borrelia burgdorferi')" ] },
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Borrelia burgdorferi')" ] },
          { "PCR" => [ "set_test_type('PCR/amplification')", "set_organism('Borrelia burgdorferi')" ] },
          { "total" => [ "set_test_type('Total Antibody')", "move_test_result_to_result_value", "set_organism('Borrelia burgdorferi')" ] }
        ]
      },

      { "Malaria" =>
        [
          { "smear" => [ "set_test_type('Microscopy')" ] }
        ]
      },

      { "Measles" =>
        [
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Measles virus')" ] },
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Measles virus')" ] }
        ]
      },

      { "Meningitis" =>
        [
          { "culture" => [ "set_test_type('Culture')" ] },
          { "PCR" => [ "set_test_type('PCR/amplification')" ] },
        ]
      },

      { "Meningococcal disease" =>
        [
          { "culture" => [ "set_test_type('Culture')", "set_organism('Neisseria meningitidis')" ] },
          { "typing" => [ "set_test_type('Typing')", "move_test_result_to_result_value" ] },
        ]
      },

      { "Mumps" =>
        [
          { "culture" => [ "set_test_type('Culture')", "set_organism('Mumps virus')" ] },
          { "dfa" => [ "set_test_type('Antigen by DFA/IF')", "set_organism('Mumps virus')" ] },
          { "eia" => [ "set_ab_test_type", "move_test_result_to_result_value", "set_organism('Mumps virus')" ] },
          { "igm" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Mumps virus')" ] },
          { "igg" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Mumps virus')" ] }
        ]
      },

      { "Necrotizing fasciitis" =>
        [
          { "culture" => [ "set_test_type('Culture')" ] }
        ]
      },

      { "Norovirus" =>
        [
          { "pcr" => [ "set_test_type('PCR/amplification')", "set_organism('Norovirus')" ] }
        ]
      },

      { "Pertussis" =>
        [
          { "culture" => [ "set_test_type('Culture')", "set_organism('Bordetella pertussis')" ] },
          { "pcr" => [ "set_test_type('PCR/amplification')", "set_organism('Bordetella pertussis')" ] },
          { "IgA" => [ "set_test_type('IgA Antibody')", "move_test_result_to_result_value", "set_organism('Bordetella pertussis')" ] },
          { "IgG" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Bordetella pertussis')" ] },
          { "IgM" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Bordetella pertussis')" ] },
          { "smear" => [ "set_test_type('Antigen by DFA/IF')", "set_organism('Bordetella pertussis')" ] },
        ]
      },

      { "Psittacosis " =>
        [
          { "igm" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Chlamydia psittaci')" ] },
          { "igg" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Chlamydia psittaci')" ] }
        ]
      },

      { "Rabies" =>
        [
          { "smear" => [ "set_test_type('Antigen by FRA')", "set_organism('Rabies virus')" ] },
        ]
      },

      { "Rocky Mountain Spotted Fever" =>
        [
          { "igm" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Rickettsia rickettsii')" ] },
          { "igg" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Rickettsia rickettsii')" ] }
        ]
      },

      { "Rubella" =>
        [
          { "igm" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('Rubella virus')" ] },
          { "igg" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('Rubella virus')" ] }
        ]
      },

      { "Salmonellosis" =>
        [
          { "Culture" => [ "set_test_type('Culture')", "move_test_result_to_result_value" ] },
          { "typ" => [ "salmon_test_type" ] }
        ]
      },

      { "Shiga" =>
        [
          { "Culture" => [ "set_test_type('Culture')" ] },
          { "eia" => [ "set_test_type('Toxin assay')" ] },
          { "typ" => [ "shiga_test_type", "move_test_result_to_result_value" ] }
        ]
      },

      { "Shigellosis" =>
        [
          { "Culture" => [ "set_test_type('Culture')" ] },
          { "typ" => [ "set_test_type('PFGE')", "move_test_result_to_result_value" ] }
        ]
      },

      { "Strep" =>
        [
          { "culture" => [ "set_test_type('Culture')" ] }
        ]
      },

      { "Syphilis" =>
        [
          { "fta" => [ "set_test_type('FTA (Fluorescent treponemal antibody)')" ] },
          { "rpr" => [ "set_test_type('RPR (Rapid plasma reagin)')", "move_test_result_to_result_value" ] }
        ]
      },

      { "Toxic" =>
        [
          { "culture" => [ "set_test_type('Culture')" ] }
        ]
      },

      { "Tuberculosis" =>
        [
          { "afb" => [ "set_test_type('Acid fast stain')" ] },
          { "smear" => [ "set_test_type('Acid fast stain')" ] },
          { "chest" => [ "set_test_type('Acid fast stain')", "set_test_result_from_lab_result_text" ] },
          { "cxr" => [ "set_test_type('Acid fast stain')", "set_test_result_from_lab_result_text" ] },
          { "radio" => [ "set_test_type('Acid fast stain')", "set_test_result_from_lab_result_text" ] },
          { "ray" => [ "set_test_type('Acid fast stain')", "set_test_result_from_lab_result_text" ] },
          { "culture" => [ "set_test_type('Culture')" ] },
          { "DNA" => [ "set_test_type('DNA probe - not amplified/PCR')" ] },
          { "NAA" => [ "set_test_type('PCR/amplification')" ] },
          { "PCR" => [ "set_test_type('PCR/amplification')" ] },
          { "PPD" => [ "set_test_type('TST (Tuberculin Skin Test)')", "move_test_result_to_result_value" ] },
          { "SKIN" => [ "set_test_type('TST (Tuberculin Skin Test)')", "move_test_result_to_result_value" ] },
          { "TST" => [ "set_test_type('TST (Tuberculin Skin Test)')", "move_test_result_to_result_value" ] },
          { "QF" => [ "set_test_type('Quantiferon')", "set_test_result_from_lab_result_text" ] },
          { "Quan" => [ "set_test_type('Quantiferon')", "set_test_result_from_lab_result_text" ] }
        ]
      },

      { "Typhoid" =>
        [
          { "culture" => [ "set_test_type('Culture')" ] }
        ]
      },

      { "Vibriosis" =>
        [
          { "culture" => [ "set_test_type('Culture')" ] }
        ]
      },

      { "West Nile virus" =>
        [
          { "igm" => [ "set_test_type('IgM Antibody')", "move_test_result_to_result_value", "set_organism('West Nile virus')" ] },
          { "igg" => [ "set_test_type('IgG Antibody')", "move_test_result_to_result_value", "set_organism('West Nile virus')" ] }
        ]
      },

      { "Yersiniosis" =>
        [
          { "culture" => [ "set_test_type('Culture')" ] },
          { "IgA" => [ "set_test_type('IgA Antibody')", "set_organism('Yersinia species')" ] },
          { "IgG" => [ "set_test_type('IgG Antibody')", "set_organism('Yersinia species')" ] },
        ]
      }
    ]
  end

  def migrate
    @map_data.each do |disease_map|
      disease_name = disease_map.keys[0]
      puts "Migrating lab results for #{disease_name} events"
    
      HumanEvent.find_in_batches(
        :include => [ :disease_event => :disease ],
        :conditions => [ "diseases.disease_name LIKE ?", "#{disease_name}%"],
        :batch_size => 500) do |events|

        events.each do |event|
          event.lab_results.each do |lr|
            print '.'
            @lab_result = lr
            lab_test_type = @lab_result['test_type']
            map_test_type = nil
            miss = true;
            disease_map.values[0].each do |test_type_map|
              set_comment

              map_test_type = test_type_map.keys[0].delete('=')
              if test_type_map.keys[0][0] != '='[0]
                map_test_type.downcase!
                lab_test_type.downcase!
              end

              if lab_test_type.include?(map_test_type)
                set_test_result
                migration_steps = test_type_map.values[0]
                migration_steps.each { |step| eval step }
                miss = false
                break
              end
            end
            if miss
              set_test_type('Unknown method')
              @lab_result.comment << "Original test type, #{lab_test_type}, not in mapping file."
            end
            begin
              @lab_result.save!
            rescue
              p @lab_result
              raise $!
            end
          end
        end
      end
      puts ""
    end

    puts "Migrating lab results for unmapped and unspecified disease events"
    LabResult.all(:conditions => [ "test_type_id IS NULL" ]).each do |lr|
      print '.'
      @lab_result = lr
      set_comment
      set_test_type('Unknown method')
      @lab_result.comment << "Lab result not associated with a disease or intentionally not mapped forward."
      @lab_result.save!
    end
    puts ""

    puts "Organisms asked for but not found."
    @unknown_organisms.each { |uo| puts uo }
    
  end

  private
    def set_test_type(test_type)
      @lab_result.test_type_id = @test_types[test_type]
    end

    def move_test_result_to_result_value
      update_result_value(@lab_result.lab_result_text)
    end

    def move_test_detail_to_result_value
      update_result_value(@lab_result.test_detail)
    end

    def update_result_value(value)
      if @lab_result.result_value.blank?
        @lab_result.result_value = value
      else
        @lab_result.result_value << " | " << value
      end
    end

    def set_test_result
      if @lab_result['interpretation_id'] == @pending_id
        @lab_result.test_status_id = @interpretations_map[@lab_result['interpretation_id']]
      else
        @lab_result.test_result_id = @interpretations_map[@lab_result['interpretation_id']]
      end
    end

    def set_organism(organism)
      if @organisms[organism]
        @lab_result.organism_id = @organisms[organism]
      else
        # raise "Organism #{organism} not found in organism table"
        @unknown_organisms << organism
      end
    end

    def set_test_result_from_lab_result_text
      return unless @lab_result.interpretation_id.blank?
      @test_result_map.each do |k, v|
        if k.downcase.include?(@lab_result.lab_result_text.downcase)
          @lab_result.test_result_id = v
          break
        end
      end
    end

    def set_comment
      comment =<<COMMENT
Migrated from TriSano version 1.x. Original Values: Test Type: #{@lab_result['test_type']}, Test Result: #{@lab_result.lab_result_text || 'N/A'},
  Test Detail: #{@lab_result.test_detail || 'N/A'}, Test interpretation: #{@interpretations[@lab_result.interpretation_id] || 'N/A'}.
COMMENT
      
      @lab_result.comment = comment
    end

    def campy_organism
      organism_map = {
        "Campylbacter jejuni" => "Campylobacter jejuni",
        "Campylobacter jejuni" => "Campylobacter jejuni",
        "Campylobacter gracilis" => "Campylobacter gracilis",
        "All others" => "Campylobacter species"
      }
      map_organism(@lab_result.lab_result_text, organism_map)
    end

    def map_organism(field, map)
      organism = map[field] ? map[field] : map["All others"]
      set_organism(organism)
    end
    
    def set_ab_test_type
      if @lab_result.test_detail.downcase.include?("igg")
        set_test_type('IgG Antibody')
      elsif @lab_result.test_detail.downcase.include?("igm")
        set_test_type('IgM Antibody')
      else
        set_test_type('Unknown method')
      end
    end

    def set_cjd_test_type
      if @lab_result.test_detail.include?("14")
        set_test_type('14-3-3 by EIA/ELISA')
      elsif @lab_result.test_detail.downcase.include?("tau")
        set_test_type('Tau protein by EIA/ELISA')
      else
        set_test_type('Unknown method')
      end
    end

    def set_giardia_test_type
      if @lab_result.lab_result_text.downcase.include?("giardia")
        set_test_type('Microscopy')
      else
        set_test_type('Unknown method')
      end
    end

    def set_gonorrhea_organism
      if @lab_result.lab_result_text.downcase.include?("gon") || @lab_result.lab_result_text.downcase.include?("gc") ||
         @lab_result.test_detail.downcase.include?("gon") || @lab_result.test_detail.downcase.include?("gc")
        set_organism('Neisseria gonorrhoeae')
      elsif @lab_result.lab_result_text.downcase.include?("chlam") || @lab_result.lab_result_text.include?("CT+") ||
         @lab_result.test_detail.downcase.include?("chlam") || @lab_result.test_detail.include?("CT+")
        set_organism('Chlamydia trachomatis')
      end
    end

    def hep_b_west
      if @lab_result.test_detail.downcase.include?('sag')
        set_test_type('Western (immuno) blot')
      else
        set_test_type('Unknown method')
      end
    end

    def hep_b_eia
      td = @lab_result.test_detail.downcase
      if td.include?('sag') || td.include?('surface antigen') || td.include?('surface ag')
        set_test_type('Surface Antigen (HBsAg)')
      elsif td.include?('sab') || td.include?('surface antibody') || td.include?('surface ab')
        set_test_type('Surface Antibody (HBsAb)')
      elsif td.include?('ca') || td.include?('core')
        set_test_type('Core Antibody (HBcAb)')
      elsif td.include?('eab') || td.include?('be ab') || td.include?('be antibody')
        set_test_type('e Antibody(HBeAb)')
      elsif td.include?('eag') || td.include?('be ag') || td.include?('be antigen')
        set_test_type('e Antigen (HBeAg)')
      else
        set_test_type('Unknown method')
      end
    end

    def hep_c_eia
      td = @lab_result.test_detail.downcase
      if td.include?('hc') || td.include?('hep c') || td.include?('hepatitis c')
        set_test_type('Total Antibody')
      else
        set_test_type('Unknown method')
      end
    end

    def lyme_eia
      td = @lab_result.test_detail.downcase
      if td.include?('igg')
        set_test_type('IgG Antibody')
      elsif td.include?('igm')
        set_test_type('IgG Antibody')
      else
        set_test_type('Unknown method')
      end
    end

    def legionellosis_organism
      if @lab_result.lab_result_text.downcase.include?("species")
        set_organism('Legionella species')
      else
        set_organism('Legionella pneumophila serogroup 1')
      end
    end

    def set_lyme_test_type
      tt = @lab_result['test_type'].downcase
      if tt.include?('igm')
        set_test_type('Western (immuno) blot (IgM)')
      elsif tt.include?('igg')
        set_test_type('Western (immuno) blot (IgG)')
      else
        td = @lab_result.test_detail.downcase
        if td.include?('igm')
          set_test_type('Western (immuno) blot (IgM)')
        elsif td.include?('igg')
          set_test_type('Western (immuno) blot (IgG)')
        else
          set_test_type('Unknown method')
        end
      end
    end

    def salmon_test_type
      tr = @lab_result.lab_result_text
      if tr =~ /.*\d.*/
        set_test_type('PFGE')
        move_test_result_to_result_value
      else
        set_test_type('Typing')
      end
    end

     def shiga_test_type
      td = @lab_result.test_detail.downcase
      if td.include?('sero')
        set_test_type('PFGE')
      else
        set_test_type('Typing')
      end
    end
end

STDOUT.sync = true
LabMigrator.new.migrate
