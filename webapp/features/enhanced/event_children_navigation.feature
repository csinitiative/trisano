Feature: Navigating directly between a CMR's children

  It's important to be able to edit related contacts and places quickly
  So, as an investigator
  I want to be able to jump between the children of a cmr w/out loading the cmr everytime

  Background:
    Given I am logged in as a super user
      And a clean events table
      And a cmr exists
      And the morbidity event has the following contacts:
        | last_name |
        | Davis     |
        | Wilson    |


  Scenario: Navigating from one sibling to another
    When I navigate to the contact named "Wilson"
     And I select "Davis" from the sibling navigator
    Then I should be on the contact named "Davis"

  Scenario: Save & Exit from one sibling to another
    When I navigate to the contact named "Wilson"
     And I enter "Fluffy" as the contact's first name
     And I select "Davis" from the sibling navigator and Save
    Then I should be on the contact named "Davis"
     And I should see "Fluffy Wilson"

  Scenario: Save & Exit from one sibling to another
    When I navigate to the contact named "Davis"
     And I enter "Magnus" as the contact's first name
     And I select "Wilson" from the sibling navigator and leave without saving
    Then I should be on the contact named "Wilson"
     And I should not see "Magnus Davis"

  Scenario: Cancel navigation
    When I navigate to the contact named "Davis"
     And I enter "Philip" as the contact's first name
     And I select "Wilson" from the sibling navigator but cancel the dialog
    Then I should be on the contact named "Davis"
     And no value should be selected in the sibling navigator
