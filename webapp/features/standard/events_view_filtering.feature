Feature: Filtering the Events view based on a set of selected criteria

  To more easily navigate through events
  As an investigator
  I want to be able to limit which events appear in the Events view

  Scenario: Limiting the events view to events in a specific state
    Given I am logged in as a super user
    Given a simple morbidity event in jurisdiction Bear River for last name Jones
    Given a routed contact event for last name Green
    Given a simple contact event in jurisdiction Bear River for last name Smith
    When I visit the events index page

    Then I should see all available event states
    And I should see a listing for Jones
    And I should see a listing for Green
    And I should not see a listing for Smith

  Scenario: Limiting the events view to events assigned to a specific queue  
    Given I am logged in as a super user
    And a queue named "Sample" in jurisdiction "Bear River"
    And a morbidity event in jurisdiction "Bear River" assigned to "Sample-BearRiver" queue
    
    When I visit the events index page
    And I select "Sample-BearRiver" from "queues_selector"
    And I press "Change View"
    
    Then I should see the assigned event
    
