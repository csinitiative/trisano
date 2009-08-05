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

Feature: Supporting LOINC codes for lab results

  To improve the clarity and consistency of electronically collected labs
  Administrators need to be able to configure the system to accept LOINC codes.

  Scenario: Listing LOINC codes
    Given I am logged in as a super user
    And I have a loinc code "13954-3" with test name "Fusce tincidunt urna ut enim ornare adipiscing."

    When I go to the loinc code index page

    Then I should see "List LOINC Codes"
    And I should see a link to "13954-3"
    And I should see "Fusce tincidunt urna ut enim ornare adipiscing."

  Scenario: Paginating the LOINC codes index page
    Given I am logged in as a super user
    And I have 31 sequential loinc codes, starting at 20000-00

    When I go to the loinc code index page
    Then I should see "20000-00"
    And I should not see "20000-30"

    When I follow "2"
    Then I should not see "20000-00"
    And I should see "20000-30"

  Scenario: Non-administrators trying to modify LOINC codes
    Given I am logged in as an investigator
    When I go to the new loinc code page
    Then I should get a 403 response

  Scenario: Creating a new LOINC code
    Given I am logged in as a super user

    When I go to the loinc code index page
    And I press "Create New LOINC Code"

    Then I should see "Create a LOINC Code"
    And I should see a link to "< Back to LOINC Codes"

    When I fill in "loinc_code_loinc_code" with "13954-3"
    And I fill in "loinc_code_test_name" with "Fusce tincidunt urna ut enim ornare adipiscing."
    And I press "Create"

    Then I should see "LOINC code was successfully created."
    And I should see "Show a LOINC Code"
    And I should see a link to "< Back to LOINC Codes"
    And I should see "13954-3"
    And I should see "Fusce tincidunt urna ut enim ornare adipiscing."

  Scenario: Entering a duplicate LOINC code
    Given I am logged in as a super user
    And I have a loinc code "13954-3" with test name ""

    When I go to the new loinc code page
    And I fill in "loinc_code_loinc_code" with "13954-3"
    And I press "Create"

    Then I should see "Loinc code has already been taken"
