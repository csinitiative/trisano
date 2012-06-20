Feature: Removing forms from events

  So that I can change an event disease and not have irrelevant forms
  As a admin
  I want to remove a form from an event

  Scenario: Morbidity event form removal as admin
    Given a morbidity event form exists for the disease African Tick Bite Fever
    And that form has 2 questions
    And that form is published
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And the disease-specific questions for the event have been answered
    And I am logged in as a super user

    When I navigate to the morbidity event edit page
    And I see the form and answers on the event
    And I click the "Add/Remove forms for this event" link
    And I check the form for removal
    And I click and confirm the "Remove Forms" button

    Then I should no longer see the form on the event
    And I should no longer see the answers on the event