Feature: Edit Event Tasks

  Because task requirements change
  As a user of TriSano
  I want to be able to edit event tasks

  Scenario: Edit CMR task status
    Given there is a morbidity event with a task
    And I am logged in as a super user
    When I go to the edit task page
    Then I should get a 200 response
    And I should see a Status option labeled "Pending"
    And I should see a Status option labeled "Complete"
    And I should see a Status option labeled "Not applicable"
    But I should not see a blank Status option

  Scenario: Edit AE task status
    Given there is a assessment event with a task
    And I am logged in as a super user
    When I go to the edit task page
    Then I should get a 200 response
    And I should see a Status option labeled "Pending"
    And I should see a Status option labeled "Complete"
    And I should see a Status option labeled "Not applicable"
    But I should not see a blank Status option
