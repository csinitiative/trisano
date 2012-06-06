Feature: Removing forms from events

  So that I can change an event disease and not have irrelevant forms
  As a manager
  I want to remove a form from an event

  Background:
    Given a morbidity event form exists for the disease African Tick Bite Fever
    And that form has 2 questions
    And that form is published
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And the disease-specific questions for the event have been answered

  Scenario: Morbidity event form removal as manager
    Given I am logged in as a manager
    When I navigate to the morbidity event edit page
    And I see the form and answers on the event
    And I click the "Add/Remove forms for this event" link
    And I check the remove form checkbox
    And I click the "Remove Forms" button
    Then I should see "The list of forms in use was successfully updated"

    When I follow "Edit CMR"
    Then I should not see the name of the added form

  Scenario: Morbidity event form removal as investigator
    Given I am logged in as an investigator
    When I navigate to the morbidity event edit page
    And I see the form and answers on the event
    And I click the "Add/Remove forms for this event" link
    And I check the remove form checkbox
    And I click the "Remove Forms" button
    Then I should see "The list of forms in use was successfully updated"

    When I follow "Edit CMR"
    Then I should not see the name of the added form

  Scenario: Morbidity event form removal as data entry tech
    Given I am logged in as a data entry tech
    When I navigate to the morbidity event edit page
    And I click the "Add/Remove forms for this event" link
    Then I should see "You do not have rights to add/remove forms."

