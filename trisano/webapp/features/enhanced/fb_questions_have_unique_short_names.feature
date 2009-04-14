Feature: All questions on a form must have a unique short name

  So as to provide a unique, floating field name to disease-specific data in the database
  As a form builder
  I want to be able to enter a unique short name for each question

  Scenario: Creating a new question without a short name
    Given I am logged in as a super user
    And a form exists with the name African Tick Bite Form (atbf_form) for a Morbidity event with the disease African Tick Bite Fever
    When I go to the Builder interface for the form
    And I try to add a question to the default section without providing a short name
    Then I should be presented with the error message "Question short name can't be blank"
    

