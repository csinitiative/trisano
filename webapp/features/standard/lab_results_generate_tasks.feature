Feature: Adding Lab Results to an Event Generates a Task

  To keep investigators aware of lab results coming in for events, a
  task will be generated for the assigned investigator, unless the
  assigned investigator entered the lab results

  Scenario: Lab result entered by investigator who is not responsible for the event
    Given I am logged in as a super user
      And a morbidity event exists with the disease Mumps
      And the following disease to common test types mapping exists
        | disease_name | common_name |
        | Mumps        | Lumpy       |
      And the event is assigned to user "investigator"
    When I go to edit the CMR
      And I click on the lab tab
      And I enter a lab name of 'Elephant Lab'
      And I select a test type of 'Lumpy'
      And I save the edit event form
    Then I should be on the show CMR page
      And I should see the following tasks:
        | Due Date | Name                        | Description | Category | Priority | Assigned to  | Status  |
        | Today    | New lab result added: Lumpy |             |          |          | investigator | Pending |

  Scenario: Lab result entered by investigator who is responsible for the event
    Given I am logged in as a super user
      And a morbidity event exists with the disease Mumps
      And the following disease to common test types mapping exists
        | disease_name | common_name     |
        | Mumps        | Something Mumpy |
      And the event is assigned to user "default_user"
    When I go to edit the CMR
      And I click on the lab tab
      And I enter a lab name of 'Elephant Lab'
      And I select a test type of 'Something Mumpy'
      And I save the edit event form
    Then I should be on the show CMR page
      And I should not see any tasks
