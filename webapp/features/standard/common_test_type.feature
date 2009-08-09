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

  Scenario: Changing the common name of a common test type
    Given I am logged in as a super user
    And I have a common test type named Culture

    When I go to the common test type show page
    And I follow "Edit"
    And I fill in "common_test_type_common_name" with "Lipid Panel"
    And I press "Update"

    Then I should not see "Culture"
    And I should see "Lipid Panel"
    And I should see "Common test type was successfully updated."

  Scenario: Changing common test type name to something invalid
    Given I am logged in as a super user
    And I have a common test type named Culture

    When I go to edit the common test type
    And I fill in "common_test_type_common_name" with ""
    And I press "Update"
    Then I should see "Common name is too short"

  Scenario: Associating LOINC codes with a common test type by test name
    Given I am logged in as a super user
    And I have a common test type named Culture
    And I have the following LOINC codes in the the system:
      | loinc_code | test_name                   |
      | 11475-1    | Culture, Unspecified        |
      | 636-1      | Culture, Sterile body fluid |
      | 34166-9    | Microscopy.Electron         |

    When I go to edit the common test type
    And I follow "LOINC codes"
    Then I should see "Add LOINC Codes to Common Test Type"
    And I should see a link to "Edit"
    And I should see a link to "Show"
    And I should see "Culture"
    And I should not see "No records found"

    When I fill in "loinc_code_search_test_name" with "junk"
    And I press "Search"
    Then I should see "No records found"

    When I fill in "loinc_code_search_test_name" with "culture"
    And I press "Search"
    Then I should see "11475-1"

    When I check "11475-1"
    And I press "Update"
    Then I should see "Common test type was successfully updated."
    And I should see "Culture, Unspecified"

  Scenario: Searching for LOINCs by code
    Given I am logged in as a super user
    And I have a common test type named Culture
    And I have the following LOINC codes in the the system:
      | loinc_code | test_name                   |
      | 11475-1    | Culture, Unspecified        |
      | 636-1      | Culture, Sterile body fluid |
      | 34166-9    | Microscopy.Electron         |

    When I go to manage the common test type's loinc codes
    And I fill in "loinc_code_search_loinc_code" with "114"
    And I press "Search"

    Then I should see a link to "11475-1"
    And I should see "Culture, Unspecified"

  Scenario: Searching should not find loincs already associated with this test type
    Given I am logged in as a super user
    And I have a common test type named Culture
    And I have the following LOINC codes in the the system:
      | loinc_code | test_name                   |
      | 11475-1    | Culture, Unspecified        |
      | 636-1      | Culture, Sterile body fluid |
      | 34166-9    | Microscopy.Electron         |
    And loinc code "11475-1" is associated with the common test type

    When I go to manage the common test type's loinc codes
    And I fill in "loinc_code_search_test_name" with "culture"
    And I press "Search"

    Then I should see "Culture, Sterile body fluid"
    And the search results should not have "Culture, Unspecified"
