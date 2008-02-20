require 'chronic'

class Person < ActiveRecord::Base
  belongs_to :birth_gender, :class_name => 'Code'
  belongs_to :current_gender, :class_name => 'Code'
  belongs_to :ethnicity, :class_name => 'Code'
  belongs_to :primary_language, :class_name => 'Code'
  belongs_to :food_handler, :class_name => 'Code'
  belongs_to :healthcare_worker, :class_name => 'Code'
  belongs_to :group_living, :class_name => 'Code'
  belongs_to :day_care_association, :class_name => 'Code'
  belongs_to :entity 

  validates_presence_of :last_name
  validates_date :birth_date, :allow_nil => true
  validates_date :date_of_death, :allow_nil => true
  
  before_save :generate_soundex_codes
  
  # Debt? Just getting this done fast after dives on options took a long time.
  # Should method this be in entity.rb? Is there a better way to handle custom
  # SQL? What about this?
  # http://www.edwardthomson.com/blog/2007/02/complex_sql_queries_with_rails.html
  def self.find_by_ts(*args)
    options = args.extract_options!
    
    where_clause = "WHERE "
    order_by_clause = "ORDER BY "
    fulltext_terms = []
    
    if !options[:fulltext_terms].blank?
      soundex_codes = []
      raw_terms = options[:fulltext_terms].split(" ")
      
      raw_terms.each do |word|
        soundex_code = Text::Soundex.soundex(word)
        soundex_codes << soundex_code.downcase unless soundex_code.nil?
        fulltext_terms << sanitize_sql(["%s", word]).sub(",", "").downcase
      end
      
      fulltext_terms << soundex_codes unless soundex_codes.empty?
      sql_terms = fulltext_terms.join(" | ")
      
      where_clause += "vector @@ to_tsquery('default', '#{sql_terms}')"
      order_by_clause += "rank(vector, '#{sql_terms}') DESC, last_name, first_name ASC;"
    end
    
    if !options[:birth_date].blank?
      # Do this if there is time
    end
    
    query = "SELECT entity_id, first_name, last_name, birth_date
      FROM (SELECT DISTINCT ON(entity_id) * FROM people ORDER BY entity_id, created_at DESC) people 
      #{where_clause} #{order_by_clause}"
    
    puts "++++++++++++++++++"
    puts query
    puts "++++++++++++++++++"
    
    find_by_sql(query)
  end

  protected
  def validate
    if !date_of_death.blank? && !birth_date.blank?
      errors.add(:date_of_death, "The date of death precedes birth date") if Chronic.parse(date_of_death) < Chronic.parse(birth_date)
    end
  end
  
  # Soundex codes are generated at save time.
  # Debt: Strip out apostrophes and hyphens? We'd have to do the same on the 
  # query side. Perhaps abstract Soundex generation out somewhere.
  def generate_soundex_codes
    if !first_name.blank?
      self.first_name_soundex = Text::Soundex.soundex(first_name)
    end
    
    self.last_name_soundex = Text::Soundex.soundex(last_name)
  end
  
end
