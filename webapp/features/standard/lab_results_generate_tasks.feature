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
      And the event is assigned to user "default"
      And a lab named "Elephant Lab"
    When I go to edit the CMR
     And I click on the lab tab
     And I select "Elephant Lab" from "Lab"
     And I select a test type of 'Lumpy'
     And I save the edit event form
    Then I should be on the show CMR page
     And I should see the following tasks:
       | Due date | Name                        | Description | Category | Priority | Assigned to  | Status  |
       | Today    | New lab result added: Lumpy |             |          | Medium   | default_user | Pending |

  Scenario: Lab result entered by investigator who is responsible for the event
    Given I am logged in as a super user
      And a morbidity event exists with the disease Mumps
      And the following disease to common test types mapping exists
        | disease_name | common_name     |
        | Mumps        | Something Mumpy |
      And the event is assigned to user "default_user"
      And a lab named "Elephant Lab"
    When I go to edit the CMR
      And I click on the lab tab
      And I select "Elephant Lab" from "Lab"
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
        | loinc_code | test_name  | common_name | loinc_scale |
        | 10000-1    | Blood Test | Blood Test  | Nom         |
        | 20000-2    | Urine Test | Urine Test  | Nom         |
        | 13954-3    | Hep-B Ag   | Hep-B Ag    | Nom         |
    When I visit the staged message show page
      And I click "Similar Events"
      And I click "Assign lab result"
    Then I should remain on the staged message show page
      And I should see a 'success' message
    When I visit the assigned-to event
    Then I should see the new lab result with 'Hep-B Ag'
      And I should see a note for the assigned lab
      And I should see the following tasks:
        | Due date | Name                           | Description | Category | Priority | Assigned to  | Status  |
        | Today    | New lab result added: Hep-B Ag |             |          | Medium   | investigator | Pending |

  Scenario: ELR assigned to event by user who is responsible for the event
    Given I am logged in as a super user
      And I have the staged message "ARUP_1"
      And there is a morbidity event with a matching name and birth date
      And the event is assigned to user "default_user"
      And the following loinc code to common test types mapping exists
        | loinc_code | test_name  | common_name | loinc_scale |
        | 10000-1    | Blood Test | Blood Test  | Nom         |
        | 20000-2    | Urine Test | Urine Test  | Nom         |
        | 13954-3    | Hep-B Ag   | Hep-B Ag    | Nom         |
    When I visit the staged message show page
      And I click "Similar Events"
      And I click "Assign lab result"
    Then I should remain on the staged message show page
      And I should see a 'success' message
    When I visit the assigned-to event
    Then I should see the new lab result with 'Hep-B Ag'
      And  I should see a note for the assigned lab
      And I should not see any tasks


