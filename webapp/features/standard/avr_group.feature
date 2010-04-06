# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

Feature: AVR Groups

  In order to simplify reporting
  Administrators need to be able to create AVR groups

  Scenario: Listing AVR groups
    Given I am logged in as a super user
    And I have an AVR group named Enterics
    When I am on the AVR groups page
    Then I should see a link to "Enterics"
    And I should see "AVR Groups"

  Scenario: Non-administrators trying to modify AVR groups
    Given I am logged in as an investigator
    When I go to the new AVR group page
    Then I should get a 403 response

  Scenario: Creating a new AVR group
    Given I am logged in as a super user
    When I am on the AVR groups page
    And I press "Create New AVR Group"
    Then I should be on the new AVR group page
    And I should see "Create AVR Group"

    When I fill in "avr_group_name" with "Enterics"
    And I press "Create"
    And I should see "Show AVR Group"
    And I should see "Enterics"

  Scenario: Entering an invalid name for an AVR group
    Given I am logged in as a super user
    And I have an AVR group named Enterics
    When I am on the new AVR group page
    And I press "Create"
    Then I should see "Name can't be blank"

    When I fill in "avr_group_name" with "Enterics"
    And I press "Create"
    Then I should see "Name has already been taken"

  Scenario: Showing an AVR group
    Given I am logged in as a super user
    And I have an AVR group named Enterics

    When I am on the AVR group show page

    Then I should see a link to "< Back to AVR Groups"
    And I should see "Enterics"

  Scenario: Changing the name of an AVR group
    Given I am logged in as a super user
    And I have an AVR group named Enterics

    When I go to the AVR group show page
    And I follow "Edit"
    And I fill in "avr_group_name" with "Stomach troubles"
    And I press "Update"

    Then I should not see "Enterics"
    And I should see "Stomach troubles"
    And I should see "AVR group was successfully updated."
