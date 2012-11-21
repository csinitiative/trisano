Feature: All questions on a form must have a unique short name

  So as to provide a unique, floating field name to disease-specific data in the database
  As a form builder
  I want to be able to enter a unique short name for each question

  @clean_forms @clean_form_elements
  Scenario: Creating a new question without a short name
    Given I am logged in as a super user
    And a Morbidity event form exists
    When I go to the Builder interface for the form
    And I try to add a question to the default section without providing a short name
    Then I should be presented with the error message "Short name can't be blank"

  @clean_forms @clean_form_elements
  Scenario: Creating a new question with a short name
    Given I am logged in as a super user
    And a Morbidity event form exists
    When I go to the Builder interface for the form
    And I try to add a question to the default section providing a short name
    Then I should not be presented with an error message

  @clean_forms @clean_form_elements
  Scenario: Creating a new question with a short name that is already in use
    Given I am logged in as a super user
    And a Morbidity event form exists
    And that form has a question with the short name "i_am_a_short_name"
    When I go to the Builder interface for the form
    And I try to add a question to the default section providing a short name that is already in use
    Then I should be presented with the error message "The short name entered is already in use on this form. Please choose another."

  @clean_forms @clean_form_elements
  Scenario: Editing a question to change its short name
    Given I am logged in as a super user
    And a Morbidity event form exists
    And that form has a question with the short name "i_am_a_short_name"
    When I go to the Builder interface for the form
    And I edit that question to change its short name to "i_am_a_new_short_name"
    Then I should not be presented with an error message
    And the new question short name should be displayed on the screen

  @clean_forms @clean_form_elements
  Scenario: Trying to edit a question short name after publishing a form
    Given I am logged in as a super user
    And a Morbidity event form exists
    And that form has a question with the short name "i_am_a_short_name"
    And that form is published
    When I go to the Builder interface for the form
    And I try to edit the question
    Then the short name should be read-only

  @clean_forms @clean_form_elements
  Scenario: Trying to copy a question from the library that has a short name that is already in use
    Given I am logged in as a super user
    And a Morbidity event form exists
    And that form has a question with the short name "i_am_a_short_name"
    And the library contains a question with the same short name
    When I go to the Builder interface for the form
    And I try to add the question from the library
    Then I should be presented with the error message "Some of the questions you are copying have short names alreay in use"

  @clean_forms @clean_form_elements
  Scenario: Creating a new question on an already published form
    Given I am logged in as a super user
    And a Morbidity event form exists
    And that form is published
    And that form has a question with the short name "i_am_a_short_name"
    When I go to the Builder interface for the form
    And I edit that question to change its short name to "i_am_a_new_short_name"
    Then I should not be presented with an error message
    And the new question short name should be displayed on the screen

