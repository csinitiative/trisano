Feature: Adding forms to events

  So that I can add forms in addition to those automatically assigned
  As an admin or investigator
  I want to add a form to an event

  Background:
    Given a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And a morbidity event form named ATBF Form 1 (aftb1) exists for the disease African Tick Bite Fever
    And that form has 2 questions
    And that form is published
    And a morbidity event form named ATBF Form 2 (aftb2) exists for the disease African Tick Bite Fever
    And that form has 2 questions
    And that form is published
    

  Scenario: Forms should display in the order in which they were added
    Given I am logged in as a super user
    And I am on the add and remove forms page
    When I check the add form checkbox for the form with the name "ATBF Form 1"
    And I click the "Add Forms" button
    Then I should see "The list of forms in use was successfully updated"

    When I check the add form checkbox for the form with the name "ATBF Form 2"
    And I click the "Add Forms" button
    Then I should see "The list of forms in use was successfully updated"

    When I navigate to the morbidity event edit page
    Then form "ATBF Form 1" should appear before "ATBF Form 2"

  Scenario: Forms should display in the order in which they were added (reverse case)
    Given I am logged in as a super user
    And I am on the add and remove forms page
    When I check the add form checkbox for the form with the name "ATBF Form 2"
    And I click the "Add Forms" button
    Then I should see "The list of forms in use was successfully updated"

    When I check the add form checkbox for the form with the name "ATBF Form 1"
    And I click the "Add Forms" button
    Then I should see "The list of forms in use was successfully updated"

    When I navigate to the morbidity event edit page
    Then form "ATBF Form 2" should appear before "ATBF Form 1"

    