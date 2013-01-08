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
class RemoveDiseaseSpecificFlagFromRaceCodes < ActiveRecord::Migration
  def self.up
    ExternalCode.connection.execute "UPDATE external_codes SET disease_specific = NULL WHERE external_codes.code_name = 'race';"
  end

  def self.down
    ExternalCode.connection.execute "UPDATE external_codes SET disease_specific = true WHERE external_codes.code_name = 'race' AND external_codes.the_code IN ('AI_AN', 'CHINESE', 'JAPANESE', 'ASIAN_INDIAN', 'KOREAN', 'VIETNAMESE', 'FILIPINO', 'ASIAN_UNSPECIFIED', 'HAWAIIAN', 'SAMOAN', 'TONGAN', 'GUATEMALAN', 'OTHER_PAC_ISLAN', 'OTHER');"
  end
end
