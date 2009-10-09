Feature: Adding Lab Results to an Event Generates a Task

  To keep investigators aware of lab results coming in for events, a
  task will be generated for the assigned investigator, unless the
  assigned investigator entered the lab results

  @wip
  Scenario: Lab result entered by investigator who is not responsible for the event
    Given I am logged in as a super user
      And a morbidity event exists
      And the event is assigned to user "investigator"

    When I go to the event edit page
