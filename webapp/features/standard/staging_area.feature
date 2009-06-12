Feature: Staging Electronic Messages

  To process electonically submitted messages
  A user needs to be able to view messages and assign them to CMRs

  @pending
  Scenario: Accessing the staging area with the right privileges
    Given I am logged in as a user with create and update privs in the Unassigned jurisdiction
    When I follow "STAGING AREA"
    Then I should see the staging area page

  @pending
  Scenario: Accessing the staging area with the wrong privileges
    Given I am logged in as a user without create and update privs in the Unassigned jurisdiction
    Then I should not see the staging area link

    When I visit the staging area page directly
    Then I should get a 403 response

  Scenario: Viewing staged messages
    Given I am logged in as a super user
    And I have the staged message "ARUP_1"
    
    When I visit the staged message show page
    
    Then I should see value "LIN GENYAO" under label "Patient"
    And  I should see value "ARUP" under label "Sending Facility"
    And  I should see value "Hepatitis Be Antigen" under label "Lab"
    And  I should see value "13954-3^Hepatitis Be Antigen^LN" under label "Test type"
    And  I should see value "2.3.1" under label "HL7 Version"
    And  I should see value "Positive" under label "Test result"
    And  I should see value "Negative" under label "Reference range"
    And  I should see value "X" under label "Specimen source"
    And  I should see value "200903191011" under label "Collection date"
    And  I should see value "200903191011" under label "Lab test date"


