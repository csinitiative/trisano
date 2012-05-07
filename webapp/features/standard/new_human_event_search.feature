Feature: Searching for existing people or events before adding a CMR or AE

  So that I can avoid duplicate data entry
  As an investigator
  I want to search for existing people or events before adding a new CMR or AE

  Scenario: Clicking 'NEW AE' link brings up a human events search form
    Given I am logged in as a super user
    When I click the "NEW AE" link
    Then I should see an assessment event search form
    And I should not see a link to enter a new AE
 
  Scenario: Creating a new AE from search criteria
    Given I am logged in as a super user
     When I search for assessment event:
       | Last name | First name | Birth date |
       | Aurelius  | Marcus     | 3/3/1972   |
      And I follow "Start an AE with the criteria you searched on"
     Then I should see the following values:
       | Last name | First name | Date of birth |
       | Aurelius  | Marcus     | March 03, 1972 |
  
  Scenario: Clicking 'NEW CMR' link brings up a morbidity event search form
    Given I am logged in as a super user
     When I click the "NEW CMR" link
     Then I should see a morbidity event search form
      And I should not see a link to enter a new CMR

  Scenario: Searching for a person uses soundex
    Given a simple morbidity event for last name Jones
      And a simple morbidity event for last name Joans
      And I am logged in as a super user
     When I search for last_name = "Jones"
     Then I should see results for Jones and Joans
      And the search field should contain Jones

  Scenario: Searches include contact, morbidity and assessment events
    Given a simple morbidity event for last name Jones
      And there is a contact on the event named Jones
      And a simple assessment event for last name Jones
      And I am logged in as a super user
     When I search for last_name = "Jones"
     Then I should see results for morbidity, contact, and assessment records

  Scenario: Searches should not include encounter events
    Given a simple morbidity event for last name Jones
      And there is an associated encounter event
      And I am logged in as a super user
     When I search for last_name = "Jones"
     Then I should see results for just the morbidity event

  Scenario: Searches do not include people without events
    Given a simple morbidity event for last name Jones
      And a person with the last name "Jones"
      And I am logged in as a super user
     When I search for last_name = "Jones"
     Then I should see the CMR but not the entity

  Scenario: Searches do not include deleted people
    Given a deleted person with the last name "Jones"
      And I am logged in as a super user
     When I search for last_name = "Jones"
     Then I should see no results

  Scenario: Searching with a name and birthdate works properly
    Given the following morbidity events:
      | last_name | first_name | birth_date |
      | Jones     | Mick       | 1955-06-26 |
      | Jones     | David      | 1947-01-08 |
      | Jones     | Steve      |            |
      And I am logged in as a super user
     When I search for last_name = "Jones"
     Then I should see the following results:
      |last_name|first_name|
      |Jones    |Mick      |
      |Jones    |David     |
      |Jones    |Steve     |

     When I search for last_name "Jones" and first_name = "David"
     Then I should see the following results:
      |last_name|first_name|
      |Jones    |David     |
      |Jones    |Mick      |
      |Jones    |Steve     |

     When I search for last name = "Jones" and birth date = "1955-06-26"
     Then I should see the following results:
      |last_name|first_name|
      |Jones    |Mick      |
      |Jones    |Steve     |

     When I search for birth date = "January 08, 1947"
     Then I should see the following results:
      |last_name|first_name|
      |Jones    |David     |

  Scenario: Handles malformed dates properly
    Given I am logged in as a super user
    When I search for birth date = "1947-01-"
    Then I should get a 422 response
     And I should see "Invalid search criteria"
     And I should see "Birth date is not a valid date"

  Scenario: Warns if a two digit year is used in birth date field
    Given I am logged in as a super user
    When I search for birth date = "Jan 8, 85"
    Then I should get a 422 response
     And I should see "Invalid search criteria"
     And I should see "Birth date is not a valid date"

  Scenario: Searching for names using starts with
    Given the following morbidity events:
      |last_name|first_name|birth_date|
      |Jones    |Mick      |1955-06-26|
      |Jones    |David     |1947-01-08|
      |Joans    |Steve     |          |
      And I am logged in as a super user

    When I search for last_name starting with "Jo"
    Then I should see the following results:
      |last_name|first_name|
      |Joans    |Steve     |
      |Jones    |David     |
      |Jones    |Mick      |

    When I search for last_name starting with "Jon"
    Then I should see the following results:
      |last_name|first_name|
      |Jones    |David     |
      |Jones    |Mick      |

    When I search for first_name starting with "Dav"
    Then I should see the following results:
      |last_name|first_name|
      |Jones    |David     |

    When I search for last_name starting with "Jo" and first_name starting with "M"
    Then I should see the following results:
      |last_name|first_name|
      |Jones    |Mick      |

  Scenario: Disease is hidden from people without the right privileges
    Given a morbidity event for last name Jones with disease Mumps in jurisdiction Davis County
      And I am logged in as a user without view or update privileges in Davis County
     When I search for last_name = "Jones"
     Then the disease should show as 'private'
     And I should the correct actions for an out-of-jurisdiction event

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
      And there is a contact on the event named Smith
      And I am logged in as a super user
     When I search for last_name = "Smith"
      And I create a new morbidity event from the contact named Smith
     Then I should be in edit mode for a new copy of Smith

  Scenario: Creating a new morb from search criteria
    Given I am logged in as a super user
     When I search for morbidity event:
       | Last name | First name | Birth date |
       | Aurelius  | Marcus     | 3/3/1972   |
      And I follow "Start a CMR with the criteria you searched on"
     Then I should see the following values:
       | Last name | First name | Date of birth |
       | Aurelius  | Marcus     | March 03, 1972 |


  Scenario: Search includes deleted records
    Given I am logged in as a super user
      And a simple morbidity event for last name Jones
      And there is a contact on the event named Smith
      And the contact event is deleted
     When I search for morbidity event:
       | Last name |
       | Smith     |
     Then the contact event search result should be styled search-inactive
