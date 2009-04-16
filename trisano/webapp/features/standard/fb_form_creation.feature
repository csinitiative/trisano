Feature: Forms can be created

  So as to provide the ability for adding disease-specific questions on an event
  As a form builder
  I want to create a disease-specific form

  Scenario: Creating a new form
    Given I am logged in as a super user

    When I navigate to the new form view
    And I enter a form name of ATBF
    And I enter a form short name of ATBF
    And I select a form event type of Morbidity event
    And I check the disease African Tick Bite Fever

    Then I should be able to create the new form and see the form name ATBF
