Feature: Routing contacts

  To allow for contacts to be investigated in foreign jurisdictions
  As an investigator
  I want to be able to route certain contacts, but not all

  Scenario: Creating a contact should put it in an "inactive" state
    Given I am logged in as a super user
     When I navigate to the new morbidity event page
      And I create an event with a contact
      And I click the "Show contact" link
     Then I should see "Not Participating in Workflow"

  Scenario: Routing an inactive contact
    Given I am logged in as a super user
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And there is a contact on the event named Jones
     When I am on the contact show page
     Then I should see "Not Participating in Workflow"
     When I route it to Bear River
     Then I should see "Assigned to Local Health Dept."

  Scenario: Routing an inactive contact to the same jurisdiction
    Given I am logged in as a super user
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And there is a contact on the event named Jones
     When I am on the contact show page
     Then I should see "Not Participating in Workflow"
     When I route it to Davis County
     Then I should see "Assigned to Local Health Dept."


