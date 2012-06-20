Feature: Persisting form builder value codes

  To allow for codes associated with values in a value set
  Values with codes should have their codes persisted to the database

  Scenario: Saving values
    Given I am logged in as a super user
    And a morbidity event form exists
    And that form has multiple questions with values on value sets
    And that form is published
    And a morbidity event exists with a disease that matches the form
    And I am on the morbidity event edit page

    When I answer all of the first questions with "No"
    And I save the event
    Then all answers answered "Yes" should have the code "1"
    And all answers answered "No" should have the code "2"
    And there should be 3 answers answered "No"
    And there should be 1 answers answered "Yes"

    When I am on the morbidity event edit page
    And I answer all of the first questions with "Yes"
    And I answer all of the second questions with "No"
    And I save the event
    Then all answers answered "Yes" should have the code "1"
    And all answers answered "No" should have the code "2"
    And there should be 3 answers answered "Yes"
    And there should be 4 answers answered "No"

    When I am on the morbidity event edit page
    And I check all check boxes
    And I save the event
    Then both check box questions should have all codes

    When I am on the morbidity event edit page
    And I save the event
    And there should be 4 answers answered "Yes"
    And there should be 4 answers answered "No"
    And there should be 2 answers answered "Unknown"
    
