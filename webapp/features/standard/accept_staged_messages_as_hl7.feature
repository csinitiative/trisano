Feature: Accept Staged Messages as HL7

  To more easily associate cases w/ lab results
  The system needs to be able to electronically accept lab orders as HL7

  # This scenario currently fails because of the disabled Create
  # button, which is activated by a JS event handler, which doesn't
  # seem to be triggered by cucumber/webrat.  Commenting out for the
  # moment, since this is only used for testing.

  #Scenario: Entering an ARUP HL7 into a web form
  #  Given I am logged in as a super user

  #  When I visit the staged message new page
  #  And I select "built-in samples" from "input_choice[type]"
  #  And I select "Arup 1" from "staged_message[hl7_message]"
  #  And I press "Create"

  #  Then I should see "Staged message was successfully created"

  Scenario: Viewing an HL7 2.5.x message
    Given I am logged in as a super user
    And I have the staged message "IHC_1"

    When I visit the staged message show page

    Then I should see value "Covell, Daren L" in the message header
    And  I should see value "IHC-LD" in the message footer

  Scenario: Viewing HL7 w/ multiple tests
    Given I am logged in as a super user
    And I have the staged message "ARUP_2"

    When I visit the staged message show page

    Then I should see value "HIV-1 Antibody Confirm, Western Blot" under label "Test type"
    And I should see value "Negative" under label "Reference range"

  Scenario: Posting a valid HL7 staged message
    Given I am logged in as a super user
    When I post the "ARUP_1" message directly to "staged_messages"
    Then I should receive a 200 response
    And the "Content-Type" HTTP header should have a value of "application/edi-hl7v2; charset=utf-8"

  Scenario: Viewing a staged message with an OBX-23 field
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    When I visit the staged message show page
    Then I should see value "GHH Lab" in the message footer

  Scenario: Viewing a staged message without an OBX-23 field
    Given I am logged in as a super user
    And I have the staged message "arup_1"
    When I visit the staged message show page
    Then I should see value "ARUP LABORATORIES" in the message footer
