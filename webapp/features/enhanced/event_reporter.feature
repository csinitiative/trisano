Feature: Adding and removing existing reporters on a CMR

  To track case reporters
  As an Investigator
  I want to be able to pick an investigator from a list of existing reporters

  Background:
    Given a basic morbidity event exists
      And the event has a reporter
      
  Scenario: Add and removing existing reporters
    When I navigate to the new morbidity event page and start a simple event
     And I select a reporter from the reporter drop down
    Then I should see the reporter on the page
    When I click on the remove reporter link
    Then I should see the reporter form
     And I should not see the reporter on the page
    When I select a reporter from the reporter drop down
     And I save and continue
    Then I should see the reporter on the page
    When I remove the reporter from the event
    Then I should see the reporter form
     And I should not see the reporter on the page
