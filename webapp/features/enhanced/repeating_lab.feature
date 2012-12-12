Feature: Form fields for repeating core sections.

  To provide users with greater control over data collections
  I want to be able to add form fields to repeating core sections.
 
  Background:
    Given I am logged in as a super user
    Given I have required repeater core field prerequisites

  Scenario: Save a CMR with repeater core forms applied, empty repeaters are ignored.
    Given   a morbidity event with with a form with repeating core fields 
    When I navigate to the morbidity event edit page
    Then I should see all of the repeater core field config questions
    And I save and exit
    Then I should see "successfully updated"
    Then I should not see any core field config repeating question

  Scenario: Creating a CMR with repeater core forms applied, save multiple labs.
    Given a published form with repeating core fields for a morbidity event

    When I navigate to the new morbidity event page and start a event with the form's disease
    And  I navigate to the Laboratory tab
    And  I enter the following lab results for the "Acme Lab" lab: 
      | test_type  |
      | TriCorder  |  
      | CAT Scan   |
    And I save and continue
    Then I should see "successfully created"
    And  I navigate to the Laboratory tab
    Then I should see all of the repeater core field config questions for 2 labs
    And I save and exit
    Then I should see "successfully updated"
    And  I navigate to the Laboratory tab
    Then I should see all of the repeater core field config questions for 2 labs

  Scenario: Editing a CMR with repeater core forms applied, save a treatment with form data.
    Given   a morbidity event with with a form with repeating core fields and labs 
    When I navigate to the morbidity event edit page
    And I answer all core field config repeating questions
    And I save and continue
    Then I should see "successfully updated"
    Then I should see all core field config repeating answers
    When I save and exit
    Then I should see "successfully updated"
    Then I should see all core field config repeating answers
    When I print the event
    Then I should see all core field config repeating answers

  Scenario: Adding forms should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see any core field config repeating question

    When I click the "Add/Remove forms for this event" link
    And I check the form for addition
    And I click the "Add Forms" button

    When I navigate to the morbidity event edit page
    Then I should see all of the repeater core field config questions
    And I answer all core field config repeating questions
    And  I save and continue
    Then I should see "successfully updated"
    Then I should see all core field config repeating answers
    When I save and exit
    Then I should see "successfully updated"
    Then I should see all core field config repeating answers
    When I print the event
    Then I should see all core field config repeating answers

  Scenario: Removing forms should remove fields for repeating core sections 
    Given a morbidity event with with a form with repeating core fields and labs

    When I navigate to the morbidity event edit page
    Then I should see all of the repeater core field config questions

    When I click the "Add/Remove forms for this event" link
    And I check the form for removal
    And I click and confirm the "Remove Forms" button

    When I navigate to the morbidity event edit page
    Then I should not see any core field config repeating question



  Scenario: Adding forms after changing diseases should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see any core field config repeating question

    When I change the disease to match the published form
    And  I save and continue
    Then I should see "successfully updated"
    And  I check the form for addition
    And  I click and confirm the "Change Forms" button
    Then I should see "successfully updated"
    Then I should see all of the repeater core field config questions
    And I answer all core field config repeating questions
    And  I save and continue
    Then I should see "successfully updated"
    Then I should see all core field config repeating answers
    When I save and exit
    Then I should see "successfully updated"
    Then I should see all core field config repeating answers
    When I print the event
    Then I should see all core field config repeating answers

  Scenario: Removing forms after changing disease should remove fields for repeating core sections 
    Given a morbidity event with with a form with repeating core fields and labs

    When I navigate to the morbidity event edit page
    Then I should see all of the repeater core field config questions

    When I change the disease to not match the published form
    And  I save and continue
    Then I should see "successfully updated"
    And  I check the form for removal
    And  I click and confirm the "Change Forms" button
    Then I should see "successfully updated"
    Then I should not see any core field config repeating question

  Scenario: Editing a CMR with repeater core forms applied, save form answers with invalid data.
