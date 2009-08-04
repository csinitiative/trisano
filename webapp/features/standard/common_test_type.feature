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

Feature: Common tests types for lab results

  In order to simplify manual lab result entry
  Administrators need to be able to create common test types.

  Scenario: Listing common test types
    Given I am logged in as a super user
    And I have a common test type named Culture

    When I go to the common test type index page

    Then I should see a link to "Culture"
    And I should see "List Common Test Types"

  Scenario: Non-administrators trying to modify common test types
    Given I am logged in as an investigator
    When I go to the new common test type page
    Then I should get a 403 response

  Scenario: Creating a new common test type
    Given I am logged in as a super user

    When I go to the common test type index page
    And I press "Create New Common Test Type"

    Then I should see "Create a Common Test Type"
    And I should see a link to "< Back to Common Test Types"

    When I fill in "common_test_type_common_name" with "Culture"
    And I press "Create"

    Then I should see "Show a Common Test Type"
    And I should see "Culture"

  Scenario: Entering an invalid common name for common test type
    Given I am logged in as a super user
    And I have a common test type named Culture

    When I go to the new common test type page
    And I press "Create"
    Then I should see "Common name is too short"

    When I fill in "common_test_type_common_name" with "Culture"
    And I press "Create"
    Then I should see "Common name has already been taken"

  Scenario: Showing a common test type
    Given I am logged in as a super user
    And I have a common test type named Culture

    When I go to the common test type show page

    Then I should see a link to "< Back to Common Test Types"
    And I should see "Culture"
