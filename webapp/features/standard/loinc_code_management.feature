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
    And I have a loinc code "13954-3" with scale "Ordinal"
    And the loinc code has test name "Fusce tincidunt urna ut enim ornare adipiscing."

    When I go to the loinc code index page

    Then I should see "List LOINC Codes"
    And I should see a link to "13954-3"
    And I should see "Ordinal"
    And I should see "Fusce tincidunt urna ut enim ornare adipiscing."

  Scenario: Paginating the LOINC codes index page
    Given I am logged in as a super user
    And I have 31 sequential loinc codes, starting at 20000-0

    When I go to the loinc code index page
    Then I should see "20000-0"
    And I should not see "20003-0"

    When I follow "2"
    Then I should not see "20000-0"
    And I should see "20003-0"

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

    When I fill in "Loinc code" with "13954-3"
    And I fill in "Test name" with "Fusce tincidunt urna ut enim ornare adipiscing."
    And I select "Quantitative" from "Scale"
    And I press "Create"

    Then I should see "LOINC code was successfully created."
    And I should see "Show a LOINC Code"
    And I should see a link to "< Back to LOINC Codes"
    And I should see "13954-3"
    And I should see "Fusce tincidunt urna ut enim ornare adipiscing."
    And I should see "Quantitative"

  Scenario: Entering a duplicate LOINC code
    Given I am logged in as a super user
    And I have a loinc code "13954-3" with scale "Nominal"

    When I go to the new loinc code page
    And I fill in "loinc_code_loinc_code" with "13954-3"
    And I press "Create"

    Then I should see "Loinc code has already been taken"

  Scenario: Editing a LOINC code
    Given I am logged in as a super user
    And I have a loinc code "636-6" with scale "Nominal"
    And the loinc code has test name "Microscopy"

    When I go to edit the loinc code
    And I fill in "Loinc code" with "636-9"
    And I press "Update"

    Then I should see "Loinc code was successfully updated"
    And I should see "636-9"
    And I should not see "636-6"

    When I follow "Edit"
    And I fill in "Test name" with "Microscopy, Electron"
    And I press "Update"

    Then I should see ", Electron"
    And I should be on the loinc code show page

    When I follow "Edit"
    Then the "Nominal" value from Scale should be selected

    When I select "Ordinal" from "Scale"
    And I press "Update"
    Then I should see "Ordinal"
    And I should not see "Nominal"

  Scenario: Entering invalid data when editing a LOINC code
    Given I am logged in as a super user
    And I have a loinc code "636-9" with scale "Ordinal"
    And the loinc code has test name "Microscopy"
    And I have a loinc code "50000-0" with scale "Quantitative"
    And the loinc code has test name "Background check"

    When I go to edit the loinc code
    And I fill in "Loinc code" with "636-9"
    And I press "Update"

    Then I should not see "Loinc code was successfully updated"
    And I should see "Loinc code has already been taken"

    When I fill in "Loinc code" with "50000-1"
    And I press "Update"

    Then I should see "Loinc code was successfully updated"
    And I should see "50000-1"

  Scenario: Deleting a LOINC code
    Given I am logged in as a super user
    And I have a loinc code "636-9" with scale "Quantitative or Ordinal"
    And the loinc code has test name "Microscopy, Electron"

    When I go to edit the loinc code
    And I follow "Delete"

    Then I should see "Loinc code was successfully deleted"
    And I should not see "636-9"
    And I should be on the loinc code index page
