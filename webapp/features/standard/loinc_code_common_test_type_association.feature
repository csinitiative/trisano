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
