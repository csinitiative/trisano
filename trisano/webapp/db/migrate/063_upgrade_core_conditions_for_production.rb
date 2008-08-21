class UpgradeCoreConditionsForProduction < ActiveRecord::Migration
  def self.up
    
    if RAILS_ENV == "production"
      transaction do
        say "Upgrading form elements: Updating core conditions for existing core follow ups"
        FormElement.find_by_sql("select * from form_elements where type = 'FollowUpElement' and core_path is not null and is_condition_code is null;").each do |element|
          unless (element.condition.to_i == 0)
            begin
              say "Checking for a matching code for FollowUpElement #{element.id}"
              code = ExternalCode.find(element.condition)
              say "Found a match: #{code.code_description}. Upgrading to code condition."
              element.is_condition_code = true
              element.save!
            rescue Exception => ex
              say "No matching code for #{element.condition}. Leaving as is."
              # No-op -- No code match
            end
          end
        end
      end
    end
    
  end

  def self.down
  end
end
