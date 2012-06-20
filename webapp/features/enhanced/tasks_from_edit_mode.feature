Feature: Creating a task from edit mode

  Scenario: Happy path task creation
    Given I am logged in as a super user
    And a simple morbidity event for last name Jones
    When I am on the morbidity event edit page
      And I click the Add Task link
      And I scroll down a bit
      And I fill in the New Task form
      And I submit the New Task form
    Then I should see "Task was successfully created."
      And the task form should not be visible
      And the flash should disappear
      And I should have been scrolled back to the top of the page
    When I am on the morbidity event show page
    Then I should see the task

  Scenario: Error during task creation
    Given I am logged in as a super user
    And a simple morbidity event for last name Jones
    When I am on the morbidity event edit page
      And I click the Add Task link
      And I scroll down a bit
      And I submit the New Task form
    Then I should see "2 errors prohibited this task from being saved"
      And I should have been scrolled back to the top of the page
    When I scroll down a bit
      And I fill in the New Task form
      And I submit the New Task form
    Then I should see "Task was successfully created."
      And the task form should not be visible
      And the flash should disappear
      And I should have been scrolled back to the top of the page
    When I am on the morbidity event show page
    Then I should see the task
