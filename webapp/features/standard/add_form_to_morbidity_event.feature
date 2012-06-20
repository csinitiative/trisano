Feature: Adding forms to events

  So that I can add forms in addition to those automatically assigned
  As an admin or investigator
  I want to add a form to an event

  Background:
    Given a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And a morbidity event form exists for the disease African Tick Bite Fever
    And that form has 2 questions
    And that form is published

  Scenario: Morbidity event form add as admin
    Given I am logged in as a super user
    When I navigate to the morbidity event edit page
    And I click the "Add/Remove forms for this event" link
    Then I should see a checkbox to add the form
    And I should see the "Add Forms" button
    
  Scenario: Morbidity event form add as investigator
    Given I am logged in as an investigator
    When I navigate to the morbidity event edit page
    And I click the "Add/Remove forms for this event" link
    Then I should see a checkbox to add the form
    And I should see the "Add Forms" button

    When I check the add form checkbox
    And I click the "Add Forms" button
    Then I should see "The list of forms in use was successfully updated"

    When I follow "Edit CMR"
    Then I should see the name of the added form

  Scenario: Morbidity event form add as investigator without checking a form to add
    Given I am logged in as an investigator
    When I navigate to the morbidity event edit page
    And I click the "Add/Remove forms for this event" link
    Then I should see a checkbox to add the form
    And I should see the "Add Forms" button

    When I click the "Add Forms" button
    Then I should see "No forms were selected for addition to this event."

    When I follow "Edit CMR"
    Then I should not see the name of the added form

  Scenario: Morbidity event form add as data entry tech
    Given I am logged in as a data entry tech
    When I navigate to the morbidity event edit page
    And I click the "Add/Remove forms for this event" link
    Then I should see "You do not have rights to add/remove forms."

  Scenario: Newer versions of forms already on the event should not be shown
    Given I am logged in as a super user
    And I am on the add and remove forms page

    When I check the add form checkbox
    And I click the "Add Forms" button
    Then I should see "The list of forms in use was successfully updated"

    When the form has been republished
    And I am on the add and remove forms page
    Then I should not see the "Add Forms" button

