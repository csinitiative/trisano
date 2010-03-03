class FixOrganismNames < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      transaction do
        organism_names.each do |names|
          fixed  = Organism.first :conditions => ['lower(organism_name) = ?', names[:fixed].downcase]
          broken = Organism.first :conditions => ['lower(organism_name) = ?', names[:broken].downcase]
          broken.try :destroy if fixed
          broken.update_attributes :organism_name => names[:fixed] unless fixed
        end
      end
    end
  end

  def self.down
  end

  def self.organism_names
    hash = YAML.load(<<-"names_end")
      ---
      - :broken: Chlamydia trachomatis infection species
        :fixed: Chlamydia species
      - :broken: Chlamydia trachomatis infection trachomatis
        :fixed: Chlamydia trachomatis
      - :broken: Chlamydia trachomatis infection trachomatis, serotype A
        :fixed: Chlamydia trachomatis, serotype A
      - :broken: Chlamydia trachomatis infection trachomatis, serotype B
        :fixed: Chlamydia trachomatis, serotype B
      - :broken: Chlamydia trachomatis infection trachomatis, serotype Ba
        :fixed: Chlamydia trachomatis, serotype Ba
      - :broken: Chlamydia trachomatis infection trachomatis, serotype C
        :fixed: Chlamydia trachomatis, serotype C
      - :broken: Chlamydia trachomatis infection trachomatis, serotype D
        :fixed: Chlamydia trachomatis, serotype D
      - :broken: Chlamydia trachomatis infection trachomatis, serotype E
        :fixed: Chlamydia trachomatis, serotype E
      - :broken: Chlamydia trachomatis infection trachomatis, serotype F
        :fixed: Chlamydia trachomatis, serotype F
      - :broken: Chlamydia trachomatis infection trachomatis, serotype I
        :fixed: Chlamydia trachomatis, serotype I
      - :broken: Chlamydia trachomatis infection trachomatis, serotype J
        :fixed: Chlamydia trachomatis, serotype J
      - :broken: Chlamydia trachomatis infection trachomatis, serotype K
        :fixed: Chlamydia trachomatis, serotype K
      - :broken: Echinococcosis species
        :fixed: Echinococcus species
      - :broken: Anaplasma phagocytophilum- Human Granulocytic Anaplasmosis, formerly Human Granulocytic Ehrlichiosis
        :fixed: Anaplasma phagocytophilum
      - :broken: Ehrlichia chaffeensis- Human Monocytic Ehrlichiosis
        :fixed: Ehrlichia chaffeensis
      - :broken: Haemophilus influenzae, invasive disease
        :fixed: Haemophilus influenzae
      - :broken: Haemophilus influenzae, invasive disease, non-typable
        :fixed: Haemophilus influenzae, non-typable
      - :broken: Haemophilus influenzae, invasive disease, type A
        :fixed: Haemophilus influenzae, type A
      - :broken: Haemophilus influenzae, invasive disease, type B
        :fixed: Haemophilus influenzae, type B
      - :broken: Haemophilus influenzae, invasive disease, type D
        :fixed: Haemophilus influenzae, type D
      - :broken: Haemophilus influenzae, invasive disease, type E
        :fixed: Haemophilus influenzae, type E
      - :broken: Haemophilus influenzae, invasive disease, type F
        :fixed: Haemophilus influenzae, type F
      - :broken: Hantavirus Infection species
        :fixed: Hantavirus (Sin Nombre)
      - :broken: Hantavirus Infection (Sin Nombre)
        :fixed: Hantavirus species
      - :broken: Hantavirus Infection (Puumala)
        :fixed: Hantavirus (Puumala)
      - :broken: Hepatitis B
        :fixed: Hepatitis B virus
      - :broken: Hepatitis C
        :fixed: Hepatitis C virus
      - :broken: Hepatitis Delta co- or super-infection, acute (Hepatitis D) virus
        :fixed: Hepatitis D virus
      - :broken: Chlamydia trachomatis infection trachomatis, serotype L2
        :fixed: Chlamydia trachomatis, serotype L2
      - :broken: Chlamydia trachomatis infection trachomatis, serotype L
        :fixed: Chlamydia trachomatis, serotype L
      - :broken: Chlamydia trachomatis infection trachomatis, serotype L1
        :fixed: Chlamydia trachomatis, serotype L1
      - :broken: Chlamydia trachomatis infection trachomatis, serotype L3
        :fixed: Chlamydia trachomatis, serotype L3
      - :broken: Chlamydia trachomatis, serotype C
        :fixed: Chlamydia trachomatis, serotype C virus
      - :broken: Western equine encephalomyelitis virus
        :fixed: Western equine encephalitis virus
      - :broken: Measles (rubeola) virus
        :fixed: Measles virus
      - :broken: Chlamydia trachomatis infection species
        :fixed: Chlamydia species
      - :broken: Chlamydia trachomatis infection psittaci
        :fixed: Chlamydia psittaci
      - :broken: Severe Acute Respiratory Syndrome (SARS) coronavirus
        :fixed: SARS coronavirus
      - :broken: Enterohemorrhagic Escherichia coli (Shiga toxin-producing Escherichia coli (STEC))
        :fixed: Enterohemorrhagic Escherichia coli (STEC)
      - :broken: CALICIVIRUS
        :fixed: Norovirus
      - :broken: Streptococcus pyogenes (Beta hemolytic Group A Streptococcus)
        :fixed: Group A strep (Streptococcus pyogenes)
  names_end
  end
end
