Feature: Manage disease details

  To provide additional value (like cdc exports) while simplifying data entry
  Administrators need to be able to customize disease info and edit metadata related to diseases.

  Scenario: Associating a common test type w/ a disease
    Given I am logged in as a super user
    And the following common test types are in the system
      | common_name  |
      | Culture      |
      | Blood        |
      | Stool        |
    And I have an active disease named "Chicken Pox"
    And I go to edit the disease

    When I check "Culture"
    And I check "Blood"
    And I press "Update"

    Then I should see "Disease was successfully updated"
    And I should see "Culture"
    And I should see "Blood"

  Scenario: Deleting the disease name
    Given I am logged in as a super user
    And I have an active disease named "Chicken Pox"
    And the following disease to common test types mapping exists
      | disease_name  | common_name |
      | Chicken Pox   | Culture     |
    And I go to edit the disease

    When I fill in "disease_disease_name" with ""
    And I press "Update"

    Then I should not see "Disease updated successfully"
    And I should see "Disease name can't be blank"

  Scenario: Create a new test type from the edit disease page
    Given I am logged in as a super user
    And I have an active disease named "Chicken Pox"

    When I go to edit the disease
    And I follow "Create a new common test type"

    Then I should be on "the new common test type page"
