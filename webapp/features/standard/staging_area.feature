Feature: Staging Electronic Messages

  To process electonically submitted messages
  A user needs to be able to view messages and assign them to CMRs

  Scenario: Accessing the staging area with the right privileges
    Given I am logged in as a user with create and update privs in the Unassigned jurisdiction
    When I follow "STAGING AREA"
    Then I should see the staging area page

  Scenario: Accessing the staging area with the wrong privileges
    Given I am logged in as a user without create and update privs in the Unassigned jurisdiction
    Then I should not see the staging area link

    When I visit the staging area page directly
    Then I should get a 403 response

  Scenario: Viewing staged messages
    Given I am logged in as a super user
    And I have the staged message "ARUP_1"
    
    When I visit the staged message show page
    
    Then I should see value "LIN, GENYAO" in the message header
    And  I should see value "Specimen: X" in the message header
    And  I should see value "Collected: 2009-03-19" in the message header
    And  I should see value "ARUP LABORATORIES" in the message header

    And  I should see value "Hepatitis Be Antigen" under label "Test Type"
    And  I should see value "Positive" under label "Result"
    And  I should see value "Negative" under label "Test Type"
    And  I should see value "2009-03-21" under label "Test Date"

  Scenario: Searching for matching events when none exist
    Given I am logged in as a super user
    And I have the staged message "ARUP_1"
    And there are no matching entries

    When I visit the staged message show page
    And I click search for the staged message
    Then I should be sent to the search results page
    And I should see the staged message
    And I should not see any matching results

  Scenario: Searching for matching events when name only match is found
    Given I am logged in as a super user
    And I have the staged message "ARUP_1"
    And there is an event with a matching name but no birth date

    When I visit the staged message show page
    And I click search for the staged message
    Then I should see matching results

  Scenario: Searching for matching events when name and birth date found
    Given I am logged in as a super user
    And I have the staged message "ARUP_1"
    And there is an event with a matching name and birth date

    When I visit the staged message show page
    And I click search for the staged message
    Then I should see matching results

  Scenario: Assigning lab result to found event
    Given I am logged in as a super user
    And I have the staged message "ARUP_1"
    And there is an event with a matching name and birth date

    When I visit the staged message show page
    And I click search for the staged message
    And I click the 'Assign lab result' link of the found event
    Then I should see the staging area page
    And I should see a success message
    And I should not see the staged message anymore

    When I visit the assigned-to event
    Then I should see the new lab result
