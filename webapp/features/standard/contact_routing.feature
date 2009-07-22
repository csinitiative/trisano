Feature: Routing contacts

  To allow for contacts to be investigated in foreign jurisdictions
  As an investigator
  I want to be able to route certain contacts, but not all

  Scenario: Creating a contact should put it in an "inactive" state
    Given I am logged in as a super user
    When I navigate to the new event page
    And I create an event with a contact
    And I click the "Show contact" link
    Then I should see "Not Participating in Workflow"

  Scenario: Routing an inactive contact
    Given I am logged in as a super user
    Given a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
    And there is a contact named Jones

    When I visit contacts show page
    Then I should see "Not Participating in Workflow"

    When I route it to Bear River
    Then I should see "Assigned to Local Health Dept."

