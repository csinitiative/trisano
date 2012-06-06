Feature: Editing contacts on morbidity events

  In order to properly investigate cases, investigators need to be
  able to add, edit, and view contact disposition data

  Scenario: Entering disposition information on a contact
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Bear River for last name Smoker
      And the morbidity event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
     When I navigate to the morbidity event edit page
      And I select "Not infected" from "Disposition"
      And I enter a valid disposition date of 2 days ago
      And I press "Save & Exit"
    Then I should be on the show CMR page
      And I should see "Not infected"
      And the disposition date of 2 days ago should be visible in show format
    When I follow "Edit contact"
    Then I should see "Not infected"
      And the disposition date of 2 days ago should be visible in edit format
    When I enter a valid disposition date of 3 days ago
      And I press "Save & Exit"
    Then the disposition date of 3 days ago should be visible in show format
    When I navigate to the morbidity event show page
    When I print the morbidity event with "All"
    Then I should see "Not infected"
    And the disposition date of 3 days ago should be visible in print format

