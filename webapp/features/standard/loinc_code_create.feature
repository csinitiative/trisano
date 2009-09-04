Feature: Creating new loinc codes

  So that electronic lab reporting can be kept current w/out
  downloading new releases, an administrator needs to be able to
  create new loinc codes in the system.

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
      And I fill in "Loinc code" with "13954-3"
      And I press "Create"
    Then I should see "Loinc code has already been taken"

  Scenario: An administrator can create a loinc and associate it with one organism
    Given I am logged in as a super user
      And an organism named "Arbovirus"
    When I go to the new loinc code page
      And I fill in "Loinc code" with "13954-3"
      And I select "Ordinal" from "Scale"
      And I select "Arbovirus" from "Organism"
      And I press "Create"
    Then I should be on the "13954-3" loinc code page
      And I should see "LOINC code was successfully created"
      And I should see "Arbovirus"