class RemoveDiseaseSpecificFlagFromRaceCodes < ActiveRecord::Migration
  def self.up
    ExternalCode.connection.execute "UPDATE external_codes SET disease_specific = NULL WHERE external_codes.code_name = 'race';"
  end

  def self.down
    ExternalCode.connection.execute "UPDATE external_codes SET disease_specific = true WHERE external_codes.code_name = 'race' AND external_codes.the_code IN ('AI_AN', 'CHINESE', 'JAPANESE', 'ASIAN_INDIAN', 'KOREAN', 'VIETNAMESE', 'FILIPINO', 'ASIAN_UNSPECIFIED', 'HAWAIIAN', 'SAMOAN', 'TONGAN', 'GUATEMALAN', 'OTHER_PAC_ISLAN', 'OTHER');"
  end
end
