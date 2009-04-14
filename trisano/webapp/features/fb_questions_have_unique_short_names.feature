Feature: All questions on a form must have a unique short name

  So as to provide a unique, floating field name to disease-specific data in the database
  As a form builder
  I want to be able to enter a unique short name for each question

  Scenario: Creating a new question
    Given I am logged in as a super user

    When I create a new form named African Tick Bite Form (atbf_form) for a Morbidity event with the disease African Tick Bite Fever
    And I navigate to the form builder interface


