Feature: Routing events through a set workflow.

  To simplify the way which morbidity events are processed by users
  I want to be able to route events through diffent states.

  Scenario: Reopening an event already received by the state.    
    Given I am logged in as a super user
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And that event has been sent to the state
    
    When I navigate to the morbidity event show page
    And the event status is "Approved by Local Health Dept."
    And I click the "Reopen" radio
    And I wait for the page to load
    
    Then the event state is "Reopened by State"


