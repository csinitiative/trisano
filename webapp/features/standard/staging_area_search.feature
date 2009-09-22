Feature: Searching the staged electronic messages

  To make it easier to find staged electronic messages, admins need to
  be able to search the staged message area.

  Scenario: Search staged messages by patient last name
    Given I am logged in as a super user
      And ELRs for the following patients:
        | Patient name |
        | David Jones  |
        | Mark Clark   |
        | Sal Benson   |
    When I go to the staged message search page
      And I fill in "Last name" with "Jones"
      And I press "Search"
    Then I should see "Jones, David"
      And I should not see "Clark, Mark"
      And I should not see "Benson, Sal"

  Scenario: Search staged messages by patient first name
    Given I am logged in as a super user
      And ELRs for the following patients:
        | Patient name |
        | David Jones  |
        | Mark Clark   |
        | Sal Benson   |
    When I go to the staged message search page
      And I fill in "First name" with "Mark"
      And I press "Search"
    Then I should not see "Jones, David"
      And I should see "Clark, Mark"
      And I should not see "Benson, Sal"

  Scenario: Search staged messages by sending facility
    Given I am logged in as a super user
      And ELRs from the following labs:
        | Lab name     |
        | ARUP         |
        | Quest        |
        | Trisano Labs |
    When I go to the staged message search page
      And I fill in "Laboratory" with "ARUP"
      And I press "Search"
    Then I should see "ARUP"
      And I should not see "Trisano Labs"
      And I should not see "Quest"

  Scenario: Search staged messages by collection date
    Given I am logged in as a super user
      And ELRs with the following collection dates:
        | Collection date |
        | 2008-05-01      |
        | 2009-06-14      |
        | 2009-08-29      |
    When I go to the staged message search page
      And I fill in "Start" with "2008-01-01"
      And I fill in "End" with "2008-12-31"
      And I press "Search"
    Then I should see "2008-05-01"
      And I should not see "2009-06-14"
      And I should not see "2009-08-29"
