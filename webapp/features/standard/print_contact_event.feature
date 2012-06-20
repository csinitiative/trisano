Feature: Printer friendly contact events

  To better be able to review cases
  An investigator
  Needs to be able to print contact events in a readable format

  Scenario: Printing a contact event
    Given I am logged in as a super user
    And I have an existing contact event
    
    When I navigate to the contact event show page
    And I choose to print "All" data
    And I press "Print"
    
    Then I should see the demographics data
    And I should see clinical data
    And I should see lab data
    And I should see epi data
    And I should see admin data
    And I should see answer data


  Scenario: Printing should display full names in section headers
    Given I am logged in as a super user
    And a simple morbidity event for full name Robert Johnson
    And the morbidity event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |

    When I go to the first CMR contact's show page
    And I choose to print "All" data
    And I press "Print"

    Then section headers should contain "Davis, Miles"

  Scenario: Printing should display full names in section headers
    Given I am logged in as a super user
    And a simple assessment event for full name Robert Johnson
    And the assessment event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |

    When I go to the first AE contact's show page
    And I choose to print "All" data
    And I press "Print"

    Then section headers should contain "Davis, Miles"
