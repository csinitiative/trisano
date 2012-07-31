Feature: Adding and removing existing reporters on a CMR

  To track case reporters
  As an Investigator
  I want to be able to pick an investigator from a list of existing reporters
      
  Scenario: Add and removing existing reporters from morbidity events
    Given a basic morbidity event exists
      And the event has a reporter
    When I navigate to the new morbidity event page and start a simple event
     And I add an existing reporter
    Then I should see the reporter on the page
    When I remove the reporter from the event
    Then I should see the reporter form
     And I should not see the reporter on the page
    When I add an existing reporter
     And I save and continue
    Then I should see the reporter on the page
    When I remove the reporter from the event
    Then I should see the reporter form
     And I should not see the reporter on the page

  Scenario: Add and removing existing reporters from assessment events
    Given a basic assessment event exists
      And the event has a reporter
    When I navigate to the new assessment event page and start a simple event
     And I add an existing reporter
    Then I should see the reporter on the page
    When I remove the reporter from the event
    Then I should see the reporter form
     And I should not see the reporter on the page
    When I add an existing reporter
     And I save and continue
    Then I should see the reporter on the page
    When I remove the reporter from the event
    Then I should see the reporter form
     And I should not see the reporter on the page
