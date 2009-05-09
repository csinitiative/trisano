Feature: Accept Lab Messages as HL7

  To more easily associate cases w/ lab results
  The system needs to be able to electronically accept lab orders as HL7

  Scenario: Entering an ARUP HL7 into a web form
    Given I am logged in as a super user
    
    When I visit the lab message new page
    And I type the "ARUP_1" message into "lab_message_hl7_message"
    And I press "Create"
    
    Then I should see "Lab message was successfully created"

  Scenario: Viewing an HL7 2.3.x message
    Given I am logged in as a super user
    And I have the lab message "ARUP_1"
    
    When I visit the lab message show page
    
    Then I should see value "LIN GENYAO" under label "Patient"
    And  I should see value "ARUP" under label "Sending Facility"
    And  I should see value "Hepatitis Be Antigen" under label "Lab"
    And  I should see value "Positive" under label "Result"
    And  I should see value "2.3.1" under label "HL7 Version"

  Scenario: Viewing an HL7 2.5.x message
    Given I am logged in as a super user
    And I have the lab message "IHC_1"
    
    When I visit the lab message show page
    
    Then I should see value "COVELL DAREN" under label "Patient"
    And  I should see value "IHC-LD" under label "Sending Facility"
    And  I should see value "" under label "Lab"
    And  I should see value "" under label "Result"
    And  I should see value "2.5" under label "HL7 Version"

  Scenario: Posting a valid HL7 lab message
    Given I am logged in as a super user
    When I post the "ARUP_1" message directly to "lab_messages"
    Then I should receive a 200 response



    
