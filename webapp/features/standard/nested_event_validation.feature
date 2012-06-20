Feature: Nested validation failure messages

  To make it easier for investigators to find mistakes and correct them
  Event validation error messages are nested within the tabs, near the actual error.

  Scenario: Invalid discharge date
    Given I am logged in as a super user
      And a basic morbidity event exists
     When I go to edit the CMR page
      And I fill in "Admission date" with "January 04, 2010"
      And I fill in "Discharge date" with "January 01, 2010"
      And I save the edit event form
     Then I should get a 422 response
      And I should have a hospital error message box
      And I should have a hospital error message containing "Discharge date must be on or after 2010-01-04"

  Scenario: Invalid discharge date
    Given I am logged in as a super user
     When I go to the new CMR page
      And I fill in "Collection date" with "January 1, 2075"
      And I save the new morbidity event form
     Then I should get a 422 response
      And I should have a lab error message box
      And I should not have a lab result error message box
      And I should have a lab error message containing "Test type can't be blank"
