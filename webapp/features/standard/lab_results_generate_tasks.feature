Feature: Adding Lab Results to an Event Generates a Task

  To keep investigators aware of lab results coming in for events, a
  task will be generated for the assigned investigator, unless the
  assigned investigator entered the lab results

  Scenario: Lab result entered by investigator who is not responsible for the event
    Given I am logged in as an investigator
      And a morbidity event exists in Bear River with the disease Mumps
      And the following disease to common test types mapping exists
        | disease_name | common_name |
        | Mumps        | Lumpy       |
      And the event is assigned to user "utah"
    When I go to edit the CMR
     And I click on the lab tab
     And I enter a lab name of 'Elephant Lab'
     And I select a test type of 'Lumpy'
     And I save the edit event form
    Then I should be on the show CMR page
     And I should see the following tasks:
       | Due date | Name                        | Description | Category | Priority | Assigned to  | Status  |
       | Today    | New lab result added: Lumpy |             |          |          | default_user | Pending |

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

  Scenario: ELR assigned to event by user who is not responsible for the event
    Given I am logged in as a user with manage_staged_message privs
      And I have the staged message "ARUP_1"
      And there is a morbidity event with a matching name and birth date
      And the event is assigned to user "investigator"
      And the following loinc code to common test types mapping exists
        | loinc_code | common_name |
        | 10000-1    | Blood Test  |
        | 20000-2    | Urine Test  |
        | 13954-3    | Hep-B Ag    |
    When I visit the staged message show page
      And I click 'Similar Events' for the staged message
      And I click the 'Assign lab result' link of the found event
    Then I should remain on the staged message show page
      And I should see a 'success' message
    When I visit the assigned-to event
    Then I should see the new lab result with 'Hep-B Ag'
      And  I should see a note for the assigned lab
      And I should see the following tasks:
        | Due date | Name                           | Description | Category | Priority | Assigned to  | Status  |
        | Today    | New lab result added: Hep-B Ag |             |          |          | investigator | Pending |

  Scenario: ELR assigned to event by user who is responsible for the event
    Given I am logged in as a super user
      And I have the staged message "ARUP_1"
      And there is a morbidity event with a matching name and birth date
      And the event is assigned to user "default_user"
      And the following loinc code to common test types mapping exists
        | loinc_code | common_name |
        | 10000-1    | Blood Test  |
        | 20000-2    | Urine Test  |
        | 13954-3    | Hep-B Ag    |
    When I visit the staged message show page
      And I click 'Similar Events' for the staged message
      And I click the 'Assign lab result' link of the found event
    Then I should remain on the staged message show page
      And I should see a 'success' message
    When I visit the assigned-to event
    Then I should see the new lab result with 'Hep-B Ag'
      And  I should see a note for the assigned lab
      And I should not see any tasks


