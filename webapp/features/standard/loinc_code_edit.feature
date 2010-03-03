Feature: Editing loinc codes

  To make the system flexible enough to keep pace with changes in public health
  Administrators need to be able to edit loinc codes

  Scenario: Non-administrators trying to modify LOINC codes
    Given I am logged in as an investigator
    When I go to the new loinc code page
    Then I should get a 403 response

  Scenario: Editing a LOINC code
    Given I am logged in as a super user
    And I have a loinc code "636-6" with scale "Nominal"
    And the loinc code has test name "Microscopy"

    When I go to edit the loinc code
    And I fill in "Loinc code" with "636-9"
    And I press "Update"

    Then I should see "LOINC code was successfully updated"
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
    And I should see "LOINC code has already been taken"

    When I fill in "Loinc code" with "50000-1"
    And I press "Update"

    Then I should see "LOINC code was successfully updated"
    And I should see "50000-1"

  Scenario: Edit a Loinc with a nominal scale
    Given I am logged in as a super user
      And I have a loinc code "50000-0" with scale "Nominal"
    When I go to the "50000-0" edit loinc code page
    Then selecting "Organism" is disabled
