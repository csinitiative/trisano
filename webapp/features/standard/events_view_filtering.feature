Feature: Filtering the Events view based on a set of selected criteria

  To more easily navigate through events
  As an investigator
  I want to be able to limit which events appear in the Events view

  Scenario: Limiting the events view to events assigned to a specific queue  
    Given I am logged in as a super user
    And a queue named "Sample" in jurisdiction "Bear River"
    And a morbidity event in jurisdiction "Bear River" assigned to "Sample-BearRiver" queue
    
    When I visit the events index page
    And I select "Sample-BearRiver" from "queues_"
    And I press "Change View"
    
    Then I should see the assigned event.
    
