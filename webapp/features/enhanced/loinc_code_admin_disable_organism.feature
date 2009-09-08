Feature: On the loinc code admin page, disable the organism field when appropriate.

  To make the user experience better and save unnecessary trips to the server
  the organism field should be disabled when we know it is not a valid option.

  @clean_loinc_codes @clean_organisms
  Scenario: Make a loinc code scale 'Nominal'
    Given I am logged in as a super user
      And I have a loinc code "12-1" with scale "Ordinal"
      And the following organisms:
        | Organism Name  |
        | Arbovirus      |
        | Monkey         |
        | Dragon         |
      And the loinc code has the organism "Arbovirus"
    When I navigate to the loinc code "12-1" edit page
      And I select "Nominal" from "Scale"
    Then the Organism field should be disabled
    When I click the "Update" button
      And I wait for the page to load
    Then I should see "Loinc code was successfully updated"
      And I should see "Nominal"
      And I should not see "Arbovirus"

  @clean_loinc_codes @clean_organisms
  Scenario: Change a loinc code scale from 'Nominal' to 'Ordinal'
    Given I am logged in as a super user
      And I have a loinc code "12-1" with scale "Nominal"
      And the following organisms:
        | Organism Name  |
        | Arbovirus      |
        | Monkey         |
        | Dragon         |
    When I navigate to the loinc code "12-1" edit page
    Then the Organism field should be disabled
    When I select "Ordinal" from "Scale"
    Then the Organism field should be enabled
    When I select "Arbovirus" from "Organism"
      And I click the "Update" button
      And I wait for the page to load
    Then I should see "Loinc code was successfully updated"
      And I should see "Ordinal"
      And I should see "Arbovirus"