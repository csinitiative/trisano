# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

Feature: Deleting common test types

  To simplify administration of common test types
  Administrators need to be able to remove common test types if they aren't being used.

  @clean_common_test_types
  Scenario: Deleting a common test type from show mode
    Given I am logged in as a super user
    And I have a common test type named Culture
    When I navigate to show common test type
    Then I should see a link to "Delete"

    When I click the "Delete" link
    Then I should see "Common test type was successfully deleted"
    And I should not see "Culture"

  @clean_common_test_types @clean_lab_results
  Scenario: Deleting a common test type referenced by a lab result
    Given I am logged in as a super user
    And I have a common test type named Culture
    And I have a lab result
    And the lab result references the common test type

    When I navigate to show common test type
    Then I should not see a link to "Delete"

