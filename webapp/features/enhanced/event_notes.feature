Feature: Notes can be added to an Event

  To aid tracking the history of an event, clinical and administrative
  notes can be added to an event.

  @clean
  Scenario: Event creation generates a note
    Given I am logged in as a super user
    When I go to the new CMR page
      And I fill in "Last name" with "Jones"
      And I enter a valid first reported to public health date
      And I press "Save & Continue"
      And I wait for the page to load
    Then I should see "Event created for jurisdiction Unassigned"

  @clean
  Scenario: Adding a clinical note
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Unassigned for last name Jones
    When I navigate to the morbidity event edit page
      And I fill in "New note" with "My first clinical note"
      And I press "Save & Continue"
      And I wait for the page to load
    Then I should see "My first clinical note"

  @clean
  Scenario: Adding an administrative note
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Unassigned for last name Jones
    When I navigate to the morbidity event edit page
      And I fill in "New note" with "My first admin note"
      And I check "Is admin"
      And I press "Save & Continue"
      And I wait for the page to load
    Then I should see "My first admin note"
