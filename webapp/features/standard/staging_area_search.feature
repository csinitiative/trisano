# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

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

  Scenario: Search staged messages by test type
    Given I am logged in as a super user
      And ELRs with the following test types:
        | Test type            |
        | Hepatitis Be Antigen |
        | SAT                  |
        | ACT                  |
    When I go to the staged message search page
      And I fill in "Test type" with "Hep"
      And I press "Search"
    Then I should see "Hepatitis Be Antigen"
      And I should not see "SAT"
      And I should not see "ACT"

  Scenario: Search staged messages w/out filling out the form
    Given I am logged in as a super user
      And ELRs with the following test types:
        | Test type            |
        | Hepatitis Be Antigen |
        | SAT                  |
        | ACT                  |
    When I go to the staged message search page
      And I press "Search"
    Then I should not see "Hepatitis Be Antigen"
      And I should not see "SAT"
      And I should not see "ACT"

  Scenario: Search staged messages with state assigned but nil assigned event
    Given I am logged in as a super user
      And ELR in assigned state with no assigned event exists
    When I visit the staging area assigned page
    Then I should see the matching result

