 should see "Country: USA, Specimen ID: 23456" on the Laboratory tabFeature: Staging Electronic Messages

  To process electonically submitted messages
  A user needs to be able to view messages and assign them to CMRs

  Scenario: Accessing the staging area with the right privileges
    Given I am logged in as a user with manage_staged_message privs
    When I follow "STAGING AREA"
    Then I should see the staging area page
    And I should not see "Create a staged message"

    Given I am logged in as a user with write_staged_message privs
    When I follow "STAGING AREA"
    Then I should see the staging area page
    And I should see "Create a staged message"

  Scenario: Accessing the staging area with the wrong privileges
    Given I am logged in as a user without staging area privs in the Unassigned jurisdiction
    Then I should not see the staging area link

    When I visit the staging area page directly
    Then I should get a 403 response

  Scenario: Viewing staged messages
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "ARUP_1"

    When I visit the staged message show page

    Then I should see value "Zhang, George" in the message header
    And  I should see value "Specimen: BLOOD" in a message specimen
    And  I should see value "Collected: 2009-03-19" in a message specimen
    And  I should see value "ARUP LABORATORIES" in the message footer

    And  I should see value "Hepatitis Be Antigen" under label "Test type"
    And  I should see value "Positive" under label "Result"
    And  I should see value "Negative" under label "Test type"
    And  I should see value "2009-03-21" under label "Test Date"

  Scenario: Searching for matching events when none exist
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "ARUP_1"
    And there are no matching entries

    When I visit the staged message show page
    And I click "Similar Events"
    Then I should be sent to the search results page
    And I should see the staged message
    And I should not see any matching results

  Scenario: Searching for matching events when name only match is found
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "ARUP_1"
    And there is a morbidity event with a matching name but no birth date

    When I visit the staged message show page
    And I click "Similar Events"
    Then I should see matching results

  Scenario: Searching for matching events when name and birth date found
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "ARUP_1"
    And there is a morbidity event with a matching name and birth date

    When I visit the staged message show page
    And I click "Similar Events"
    Then I should see matching results

  Scenario: Assigning lab result to found event
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "ARUP_1"
    And there is a morbidity event with a matching name and birth date
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name  | common_name | loinc_scale |
      | 10000-1    | Blood Test | Blood Test  | Nom         |
      | 20000-2    | Urine Test | Urine Test  | Nom         |
      | 13954-3    | Hep-B Ag   | Hep-B Ag    | Nom         |

    When I visit the staged message show page
      And I click "Similar Events"
      And I click "Assign lab result"
    Then I should remain on the staged message show page
      And I should see a 'success' message

    When I visit the assigned-to event
    Then I should see the new lab result with 'Hep-B Ag'
    And  I should see a note for the assigned lab
    And  I should see a link back to the staged message

    When I navigate to the event edit page
    Then I should see a link back to the staged message

  Scenario: Assigning lab result to found contact event
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "ARUP_1"
    And there is a contact event with a matching name and birth date
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name  | common_name | loinc_scale |
      | 10000-1    | Blood Test | Blood Test  | Nom         |
      | 20000-2    | Urine Test | Urine Test  | Nom         |
      | 13954-3    | Hep-B Ag   | Hep-B Ag    | Nom         |

    When I visit the staged message show page
    And I click "Similar Events"
    And I click "Assign lab result"
    Then I should remain on the staged message show page
    And I should see a 'success' message
    And I should not see the 'Similar Events' link
    And I should not see the 'Discard' link

    When I visit the assigned-to event
    Then I should see the new lab result with 'Hep-B Ag'
    And  I should see a note for the assigned lab
    And  I should see a link back to the staged message

  Scenario: Assigning lab result to new event
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "ARUP_1"
    And there is a morbidity event with a matching name and birth date
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name  | common_name | loinc_scale |
      | 10000-1    | Blood Test | Blood Test  | Nom         |
      | 20000-2    | Urine Test | Urine Test  | Nom         |
      | 13954-3    | Hep-B Ag   | Hep-B Ag    | Nom         |

    When I visit the staged message show page
    And I click "Similar Events"
    And I click 'Create a CMR from this message'
    Then I should remain on the staged message show page
    And I should see a 'success' message
    And I should not see the 'Similar Events' link
    And I should not see the 'Discard' link

    When I visit the assigned-to event
    Then I should see the patient information
    And I should see the new lab result with 'Hep-B Ag'
    And I should see a note for the assigned lab
    And I should see a link back to the staged message

  Scenario: Assigning lab result to a new event with an existing person
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "ARUP_1"
    And there is a morbidity event with a matching name and birth date
    And that event also has a middle name of George
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name  | common_name | loinc_scale |
      | 10000-1    | Blood Test | Blood Test  | Nom         |
      | 20000-2    | Urine Test | Urine Test  | Nom         |
      | 13954-3    | Hep-B Ag   | Hep-B Ag    | Nom         |

    When I visit the staged message show page
    And I click "Similar Events"
    And I click "Assign to new CMR using this person"
    Then I should see a 'success' message

    When I visit the assigned-to event
    Then I should see the new lab result with 'Hep-B Ag'
    And I should see a middle name of George

  Scenario: Attempting to assign message with unknown LOINC code
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "UNKNOWN_LOINC"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name  | common_name | loinc_scale |
      | 10000-1    | Blood Test | Blood Test  | Nom         |

    When I visit the staged message show page
    And I click "Similar Events"
    And I click 'Create a CMR from this message'

    Then I should see a 'All LOINC codes in message unknown or unlinked' message
    And I should see a state of 'Unprocessable'

  Scenario: Attempting to assign message with unlinked LOINC code
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "UNLINKED_LOINC"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name  | common_name | loinc_scale |
      | 10000-1    | Blood Test |             | Nom         |

    When I visit the staged message show page
    And I click "Similar Events"
    And I click 'Create a CMR from this message'

    Then I should remain on the staged message show page
    Then I should see a 'All LOINC codes in message unknown or unlinked' message
    And I should see a state of 'Unprocessable'

  Scenario: Discarding a message
    Given I am logged in as a user with manage_staged_message privs
    And I have the staged message "ARUP_1"
    And there is a morbidity event with a matching name and birth date

    When I visit the staged message show page
    And I click the 'Discard' link for the staged message
    Then I should see the staging area page
    And I should see a 'Staged message was discarded' message
    And I should not see the discarded message

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

  Scenario: Assigning a staged message with a home phone number
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    Then I should receive a 200 response
    And I should remain on the staged message show page
    And I should see value "Assigned" in the message footer

  Scenario: Viewing a staged message with a home phone number
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Home" under Telephones/Email on the Demographic tab
    And I should see "(555) 555-2004" under Telephones/Email on the Demographic tab

  Scenario: Viewing a staged message with a work phone number
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Work" under Telephones/Email on the Demographic tab
    And I should see "(955) 555-1009" under Telephones/Email on the Demographic tab

  Scenario: Viewing a staged message with a cell phone number
    Given I am logged in as a super user
    And I have the staged message "realm_cj_cell_phone"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Mobile" under Telephones/Email on the Demographic tab

  Scenario: Assigning a staged message with a lab name
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "GHH Lab" on the Laboratory tab

  Scenario: Assigning a staged message with an ethnicity
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Not Hispanic or Latino" under "Ethnicity" on the Demographic tab

  Scenario: Assigning a staged message with a collection date
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "2008-08-15" on the Laboratory tab

  Scenario: Assigning a staged message with a test date
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "2009-06-05" on the Laboratory tab

  Scenario: Assigning a staged message with a test status
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Final" on the Laboratory tab

  Scenario: Assigning a staged message with comment fields
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Country: USA, Specimen ID: 23456" on the Laboratory tab

  Scenario: Assigning a staged message with a dead patient
    Given I am logged in as a super user
    And I have the staged message "realm_cj_died"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "2010-11-11" on the Clinical tab

  Scenario: Assigning a staged message for an inpatient
    Given I am logged in as a super user
    And I have the staged message "realm_cj_inpatient"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    And the following organism mapping exists
      | organism_name        | disease_name       |
      | Campylobacter jejuni | Campylobacteriosis |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should have a disease event
    And I should see "Level Seven Healthcare" on the Clinical tab

  Scenario: Assigning a staged message with a parent/guardian
    Given I am logged in as a super user
    And I have the staged message "realm_lead_laboratory_result"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name     | common_name     | loinc_scale |
      | 10368-9    | Lead BldCmCnc | Blood lead test | Qn          |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Mum, Martha" under "Parent/Guardian" on the Demographic tab

  Scenario: Assigning a staged message with a language code
    Given I am logged in as a super user
    And I have the staged message "realm_cj_en"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name     | loinc_scale |
      | 625-4      | Bacteria identified | Culture         | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    And I should see "English" under "Primary language" on the Demographic tab

  Scenario: Assigning a staged message with a CE value in OBX-5
    Given I am logged in as a super user
    And I have the staged message "realm_cj_ce"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    And I should see "Uncultured" on the Laboratory tab

  Scenario: Assigning a staged message with an SN value in OBX-5
    Given I am logged in as a super user
    And I have the staged message "realm_hepatitis_c_virus"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name     | loinc_scale |
      | 5198-7     | HCV Ab Ser EIA-aCnc | Total Antibody  | Qn          |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    And I should see "> 11.0" on the Laboratory tab

  Scenario: Assigning a staged message with a clinician in the OBR segment
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Admit, Alan" on the Clinical tab
    And I should see "Work: (555) 555-1005" on the Clinical tab

  Scenario: Assigning a staged message with a clinician in the ORC segment
    Given I am logged in as a super user
    And I have the staged message "nist_orc_clinician"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name                   | common_name | loinc_scale |
      | 625-4      | Bacteria identified         | Culture     | Nom         |
      | 6331-3     | Campylobacter sp identified | Culture     | Nom         |
      | 17576-0    | Shigella sp identified      | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Moreau, Glenda" on the Clinical tab
    And I should see "Work: (800) 555-1212" on the Clinical tab

  Scenario: Assigning a staged message with clinicians in the PV1 segment
    Given I am logged in as a super user
    And I have the staged message "realm_cj_clinicians"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Admit, Alan" on the Clinical tab
    And I should see "Work: (555) 555-1005" on the Clinical tab
    And I should see "Jekyll, Susan" on the Clinical tab
    And I should see "Hyde, Herbert" on the Clinical tab

  Scenario: Assigning a staged message with a specimen in SPM-8
    Given I am logged in as a super user
    And I have the staged message "realm_lead_laboratory_result"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name     | common_name     | loinc_scale |
      | 10368-9    | Lead BldCmCnc | Blood lead test | Qn          |
    And the following specimen mappings exist
      | specimen                  | the_code |
      | Venous structure of digit | VSD      |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Venous structure of digit" on the Laboratory tab

  Scenario: Assigning a staged message with an address in PID-11
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "2222" under "Street number" on the Demographic tab
    And I should see "Home Street" under "Street name" on the Demographic tab
    And I should see "Ann Arbor" under "City" on the Demographic tab
    And I should see "Michigan" under "State" on the Demographic tab
    And I should see "99999" under "Zip code" on the Demographic tab

  Scenario: Assigning a staged message with a reference range
    Given I am logged in as a super user
    And I have the staged message "realm_lead_laboratory_result"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name     | common_name     | loinc_scale |
      | 10368-9    | Lead BldCmCnc | Blood lead test | Qn          |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "<10 ug/dL" on the Laboratory tab

  Scenario: Assigning a staged message with basic personal info in PID-5, 7 and 8
    Given I am logged in as a super user
    And I have the staged message "realm_campylobacter_jejuni"
    And the following loinc code to common test types mapping exists
      | loinc_code | test_name           | common_name | loinc_scale |
      | 625-4      | Bacteria identified | Culture     | Nom         |
    When I visit the staged message show page
    And I follow "Similar Events"
    And I create a new CMR from the message
    And I visit the assigned-to event
    Then I should see "Everyman" under "Last name" on the Demographic tab
    And I should see "Adam" under "First name" on the Demographic tab
    And I should see "A" under "Middle name" on the Demographic tab
    And I should see "1980-06-02" under "Date of birth" on the Demographic tab
    And I should see "Male" under "Birth gender" on the Demographic tab
