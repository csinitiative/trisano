Feature: Searching for existing people or events before adding a CMR

  So that I can avoid duplicate data entry
  As an investigator
  I want to search for existing people or events before adding a new CMR

  Scenario: Clicking 'NEW CMR' link brings up a search form
    Given I am logged in as a super user

    When I click the "NEW CMR" link
    Then I should see a search form
    And I should not see a link to enter a new CMR

  Scenario: Searching for a person uses soundex
    Given a simple morbidity event for last name Jones
    And a simple morbidity event for last name Joans
    And I am logged in as a super user

    When I search for last_name = "Jones"
    Then I should see results for Jones and Joans
    And the search field should contain Jones

  Scenario: Searches include contact and morbidity events
    Given a simple morbidity event for last name Jones
    And there is a contact named Jones
    And I am logged in as a super user

    When I search for last_name = "Jones"
    Then I should see results for both records

  Scenario: Searching with a name and birthdate works properly
    Given the following morbidity events:
      |last_name|first_name|birth_date|
      |Jones    |Mick      |1955-06-26|
      |Jones    |David     |1947-01-08|
      |Jones    |Steve     |          |
    And I am logged in as a super user

    When I search for last_name = "Jones"
    Then I should see the follwing results:
      |last_name|first_name|
      |Jones    |Steve     |
      |Jones    |David     |
      |Jones    |Mick      |

    When I search for last_name "Jones" and first_name = "David"
    Then I should see the follwing results:
      |last_name|first_name|
      |Jones    |David     |
      |Jones    |Steve     |
      |Jones    |Mick      |

    When I search for last name = "Jones" and birth date = "1955-06-26"
    Then I should see the follwing results:
      |last_name|first_name|
      |Jones    |Mick      |
      |Jones    |Steve     |
    
  Scenario: Disease is hidden from people without the right privileges
    Given a morbidity event for last name Jones with disease Mumps in jurisdiction Davis County
    And I am logged in as a user without view or update privileges in Davis County

    When I search for last_name = "Jones"
    Then the disease should show as 'private'

  Scenario: People with multiple events are grouped together
    Given there are 2 morbidity events for a single person with the last name Jones
    And I am logged in as a super user
    
    When I search for last_name = "Jones"
    Then I should see two morbidity events under one name

  Scenario: Creating a new morb event from an existing morb event
    Given a simple morbidity event for last name Jones
    And I am logged in as a super user

    When I search for last_name = "Jones"
    And I create a new morbidity event from the morbidity named Jones
    Then I should be in edit mode for a new copy of Jones
    
  Scenario: Creating a new morb event from an existing contact event
    Given a simple morbidity event for last name Jones
    And there is a contact named Smith
    And I am logged in as a super user

    When I search for last_name = "Smith"
    And I create a new morbidity event from the contact named Smith
    Then I should be in edit mode for a new copy of Smith
