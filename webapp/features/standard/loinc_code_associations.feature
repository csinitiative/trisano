Feature: Associate common test types with loinc codes

  To simplify entering loinc codes into the system, administrators
  need to be able to associate common test types with loinc codes from
  the loinc code screen.

  Scenario: Change common test type on Loinc
    Given I am logged in as a super user
      And LOINC code "10000-1"
      And common test type "Arbovirus"
    When I go to edit LOINC code "10000-1"
      And I select "Arbovirus" from "Common test type"
      And I press "Update"
    Then I should see "Loinc code was successfully updated"
      And I should see "Arbovirus"

  Scenario: Associate a Loinc code with a diseases
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name             |
        | African Tick Bite Fever  |
        | Dengue                   |
      And LOINC code "10000-1"
    When I go to edit LOINC code "10000-1"
      And I check "African Tick Bite Fever"
      And I check "Dengue"
      And I press "Update"
    Then I should be on the LOINC code "10000-1" page
      And I should see "Loinc code was successfully updated"
      And I should see "African Tick Bite Fever"
      And I should see "Dengue"

  Scenario: Delete a disease's association with a loinc code
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name             |
        | African Tick Bite Fever  |
        | Dengue                   |
      And LOINC code "10000-1"
      And disease "Dengue" is associated with LOINC code "10000-1"
      And disease "African Tick Bite Fever" is associated with LOINC code "10000-1"
    When I go to the LOINC code "10000-1" page
    Then I should see "Dengue"
      And I should see "African Tick Bite Fever"
    When I follow "Edit"
      And I uncheck "Dengue"
      And I uncheck "African Tick Bite Fever"
      And I press "Update"
    Then I should see "Loinc code was successfully updated"
      And I should not see "Dengue"
      And I should not see "African Tick Bite Fever"


