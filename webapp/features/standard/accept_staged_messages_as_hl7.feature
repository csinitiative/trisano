Feature: Accept Staged Messages as HL7

  To more easily associate cases w/ lab results
  The system needs to be able to electronically accept lab orders as HL7

  Scenario: Entering an ARUP HL7 into a web form
    Given I am logged in as a super user
    
    When I visit the staged message new page
    And I type the "ARUP_1" message into "staged_message_hl7_message"
    And I press "Create"
    
    Then I should see "Staged message was successfully created"

  Scenario: Viewing an HL7 2.3.x message
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

  Scenario: Viewing an HL7 2.5.x message
    Given I am logged in as a super user
    And I have the staged message "IHC_1"
    
    When I visit the staged message show page
    
    Then I should see value "COVELL DAREN" under label "Patient"
    And  I should see value "IHC-LD" under label "Sending Facility"
    And  I should see value "2.5" under label "HL7 Version"

 Scenario: Viewing HL7 w/ multiple tests
   Given I am logged in as a super user
   And I have the staged message "ARUP_2"
   
   When I visit the staged message show page

   Then I should see value "5221-7^HIV-1 Antibody Confirm, Western Blot^LN" under label "Test type"
   And I should see value "^Bordatella Per^LN" under label "Test type"
   

  Scenario: Posting a valid HL7 staged message
    Given I am logged in as a super user
    When I post the "ARUP_1" message directly to "staged_messages"
    Then I should receive a 200 response



    
