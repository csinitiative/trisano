Feature: Removing forms from events

  So that I can change an event disease and not have irrelevant forms
  As a manager
  I want to remove a form from an event

  Scenario: Morbidity event form removal as manager
    Given a morbidity event form exists for the disease African Tick Bite Fever
    And that form has 2 questions
    And that form is published
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And the forms for the event have been assigned
    And the disease-specific questions for the event have been answered
    And I am logged in as a manager

    When I navigate to the event edit page
    And I see the form and answers on the event
    And I click the "Add/Remove forms for this event" link
    
    Then I should be presented with the error message "You do not have rights to add/remove forms"

  Scenario: Morbidity event form removal as investigator
    Given a morbidity event form exists for the disease African Tick Bite Fever
    And that form has 2 questions
    And that form is published
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And the forms for the event have been assigned
    And the disease-specific questions for the event have been answered
    And I am logged in as an investigator

    When I navigate to the event edit page
    And I see the form and answers on the event
    And I click the "Add/Remove forms for this event" link
    
    Then I should be presented with the error message "You do not have rights to add/remove forms"