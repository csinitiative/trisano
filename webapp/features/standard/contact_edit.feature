Feature: Editing contacts

  In order to properly investigate cases, investigators need to be
  able to edit contact information in more detail then is possible
  just on the parent cmr.

  Scenario: Navigating to the parent cmr in edit mode
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Bear River for last name Smoker
      And the morbidity event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
     When I go to the first CMR contact's edit page
       And I follow "Smoker"
     Then I should be on edit the CMR

  Scenario: Navigating to the parent AE in edit mode
    Given I am logged in as a super user
      And a simple assessment event in jurisdiction Bear River for last name Smoker
      And the assessment event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
     When I go to the first AE contact's edit page
       And I follow "Smoker"
     Then I should be on edit the AE
