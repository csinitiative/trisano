Feature: Viewing paginated contact search results in-line

  Scenario: Viewing paginated contact search results
    Given I am logged in as a super user
      And 25 simple morbidity events for last name Jones
      And 25 simple morbidity events for last name Johnes
    When I am on the morbidity event edit page
      And I do a contact search for "Jones"
    Then I should see the contact pagination navigation
      And "Johnes" should not be present in the contact search results

    When I follow the last pagination navigation link
    Then "Johnes" should be present in the contact search results
