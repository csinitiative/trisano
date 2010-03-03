Feature: Selecting and deselecting all place

  To enable merging of many places
  As an admin
  I want to be able to select or deselect all place check boxes in place search results

  Scenario: Selecting all places
    Given three similar labs exist with "Manzanita" in the name
    And I am logged in as a super user
    When I navigate to the place management tool
    And I search for a place named Manzanita
    And I click merge for the first lab
    And I click the select-all option
    Then all merge check boxes should be selected

    When I click the select-none option
    Then all merge check boxes should not be selected

