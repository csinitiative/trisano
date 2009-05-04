Feature: Accept Lab Messages as HL7

  To more easily associate cases w/ lab results
  The system needs to be able to electronically accept lab orders as HL7

  Scenario: Entering an ARUP HL7 into a web form
    Given I am logged in as a super user
    
    When I visit the lab message new page
    And I type the "ARUP" message into "lab_message_hl7_message"
    And I press "Create"
    
    Then I should see "Lab message was successfully created"

  Scenario: Viewing an ARUP HL7 message
    Given I am logged in as a super user
    And I have a lab message from "ARUP"
    
    When I visit the lab message show page
    
    Then I should see the sending facility
    And I should see the patient's name
    And I should see the lab name
    And I should see the lab result
    And I should see the HL7 version

  Scenario: Accepting an ARUP HL7 orders directly as an HL7 message
