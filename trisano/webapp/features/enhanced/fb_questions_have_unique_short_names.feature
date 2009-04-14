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

  Scenario: Creating a new question with a short name
    Given I am logged in as a super user
    And a form exists with the name African Tick Bite Form (another_atbf_form) for a Morbidity event with the disease African Tick Bite Fever
    When I go to the Builder interface for the form
    And I try to add a question to the default section providing a short name
    Then I should not be presented with an error message

  Scenario: Creating a new question with a short name that is already in use
    Given I am logged in as a super user
    And a form exists with the name African Tick Bite Form (yet_another_atbf_form) for a Morbidity event with the disease African Tick Bite Fever
    And that form has a question with the short name "i_am_a_short_name"
    When I go to the Builder interface for the form
    And I try to add a question to the default section providing a short name that is already in use
    Then I should be presented with the error message "The short name entered is already in use on this form. Please choose another."
