Feature: Form fields for repeating core sections.

  To provide users with greater control over data collections
  I want to be able to add form fields to repeating core sections.
 
  Background:
    Given I am logged in as a super user
    

  Scenario: Creating CMR with no core forms are applied, save multiple treatments.
    When I navigate to the new morbidity event page and start a simple event
    And  I navigate to the Clinical tab
    Then I should see a link to "Add a Treatment"
    Then I should not see treatment save and discard buttons

    When I enter the following treatments: 
      | treatment_date   |
      | November 3, 2001 |         
      | November 4, 2001 |
    And I save and exit
    Then I should see "2001-11-03"
    And  I should see "2001-11-04"
    And  I navigate to the morbidity event edit page
    And  I navigate to the Clinical tab
    And  I should see a link to "Add a Treatment"
    And  I should not see treatment save and discard buttons




  Scenario: Creating a CMR with repeater core forms applied, save multiple treatments.
    Given a published form with repeating core fields for a morbidity event

    When I navigate to the new morbidity event page and start a event with the form's disease
    And  I navigate to the Clinical tab
    Then I should not see treatment save and discard buttons
    And  I should see a link to "Add a Treatment"

    When I enter the following treatments: 
      | treatment_date    |
      | November 5, 2001  |    
      | November 6, 2001  |    
    And I save and continue
    And  I navigate to the Clinical tab
    Then I should see all of the repeater core field config questions for 2 treatment
    And I save and exit
    And  I navigate to the Clinical tab
    Then I should see all of the repeater core field config questions for 2 treatment



  Scenario: Editing CMR with no core forms are applied, save multiple treatments.
    Given a basic assessment event exists
    Given a treatment named "leeching"
    Given a treatment named "sleeping"

    When I navigate to the assessment event edit page
    Then I should not see a link to "Add a Treatment"
    And  I should see treatment save and discard buttons

    When I enter the following treatments: 
      | treatment_name         |
      | leeching          |       
      | sleeping          |
    And I save and exit
    Then I should see "leeching"
    And  I should see "sleeping"
    And I navigate to the assessment event edit page
    And I navigate to the Clinical tab
    And I should see a link to "Add a Treatment"
    And I should not see treatment save and discard buttons



  Scenario: Editing a CMR with repeater core forms applied and one treatment, save/discard/add buttons should work as expected.
    Given a assessment event with with a form with repeating core fields and treatments

    When I navigate to the assessment event edit page
    And  I navigate to the Clinical tab
    Then I should see 0 blank treatment form
    Then I should not see treatment save and discard buttons
    And  I should see a link to "Add a Treatment"
    
    When I click the "Add a Treatment" link and don't wait
    Then I should see treatment save and discard buttons
    And  I should not see a link to "Add a Treatment"

    When I discard the unsaved treatment
    Then I should see a link to "Add a Treatment"
    Then I should not see treatment save and discard buttons


  Scenario: Editing a CMR with repeater core forms applied and zero treatments, save/discard/add buttons should work as expected.
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Clinical tab
    Then I should see 1 blank treatment form
    Then I should see treatment save and discard buttons
    And  I should not see a link to "Add a Treatment"
    
    When I discard the unsaved treatment
    Then I should see a link to "Add a Treatment"
    Then I should not see treatment save and discard buttons

    When I click the "Add a Treatment" link and don't wait
    Then I should see treatment save and discard buttons
    And  I should not see a link to "Add a Treatment"


  Scenario: Editing a CMR with repeater core forms applied, save a treatment with form data.
    Given a morbidity event with with a form with repeating core fields
    Given a treatment named "leeching"

    When I navigate to the morbidity event edit page
    And  I navigate to the Clinical tab
    And  I enter the following treatments: 
      | treatment_name         |
      | leeching          |           
    And I fill in "morbidity_event[interested_party][treatments][treatment_date] before?" with "treatment before"
    And I fill in "morbidity_event[interested_party][treatments][treatment_date] after?" with "treatment after"
    And  I click the Treatment Save link
    
    Then I should not see treatment save and discard buttons
    And  I should see a link to "Add a Treatment"

    When I save and exit
    Then I should see "leeching"
    And  I should see "treatment before"
    And  I should see "treatment after"

    When I print the event
    Then I should see "leeching"
    And  I should see "treatment before"
    And  I should see "treatment after"

  Scenario: Editing a CMR with repeater core forms applied, create and then discard a treatment.
    Given   a assessment event with with a form with repeating core fields and treatments 
    And     a treatment named "new_treatment"

    When I navigate to the assessment event edit page
    And  I navigate to the Clinical tab
    And  I enter a second treatment: 
      | treatment_name    |
      | new_treatment     |           
    And  I discard the unsaved treatment
    
    Then I should not see treatment save and discard buttons
    And  I should see a link to "Add a Treatment"

    When I save and exit
    Then I should not see "new_treatment"
    
  Scenario: Adding forms should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[interested_party][treatments][treatment_date] before?"

    When I click the "Add/Remove forms for this event" link
    And I check the form for addition
    And I click the "Add Forms" button

    When I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[interested_party][treatments][treatment_date] before?"

  Scenario: Removing forms should remove fields for repeating core sections 
    Given a assessment event with with a form with repeating core fields and treatments

    When I navigate to the assessment event edit page
    Then I should see a label "assessment_event[interested_party][treatments][treatment_date] before?"

    When I click the "Add/Remove forms for this event" link
    And I check the form for removal
    And I click and confirm the "Remove Forms" button

    When I navigate to the assessment event edit page
    Then I should not see a label "assessment_event[interested_party][treatments][treatment_date] before?"



  Scenario: Adding forms after changing diseases should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[interested_party][treatments][treatment_date] before?"

    When I change the disease to match the published form
    And  I save and continue
    And  I check the form for addition
    And  I click and confirm the "Change Forms" button
    And  I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[interested_party][treatments][treatment_date] before?"

  Scenario: Removing forms after changing disease should remove fields for repeating core sections 
    Given a morbidity event with with a form with repeating core fields and treatments

    When I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[interested_party][treatments][treatment_date] before?"

    When I change the disease to not match the published form
    And  I save and continue
    And  I check the form for removal
    And  I click and confirm the "Change Forms" button
    And  I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[interested_party][treatments][treatment_date] before?"

  Scenario: When editing a CMR, unsaved treatmentes are saved automatically with the event, even when the user is on another tab
    Given   a assessment event with with a form with repeating core fields
    Given a treatment named "leeching"

    When I navigate to the assessment event edit page
    And  I navigate to the Clinical tab
    And  I enter the following treatments: 
      | treatment_name         |
      | leeching          |           
    And I navigate to the Clinical tab
    And  I save and exit
    Then I should see "leeching"



  Scenario: Editing CMR with repeating core forms are applied, save multiple treatments individually.
    Given   a morbidity event with with a form with repeating core fields
    Given a treatment named "leeching"
    Given a treatment named "sleeping"

    When I navigate to the morbidity event edit page
    And  I navigate to the Clinical tab
    And  I enter the following treatments: 
      | treatment_name         |
      | leeching          |           
    And  I click the Treatment Save link
    When I enter a second treatment: 
      | treatment_name         |
      | sleeping          |           
    And  I click the Treatment Save link
    Then I should see the following in order:
    | leeching |
    | sleeping |


  Scenario: Creating a CMR with repeater core forms applied, save form answers.
    Given a published form with repeating core fields for a morbidity event
    Given a treatment named "leeching"

    When I navigate to the new morbidity event page and start a event with the form's disease
    And  I navigate to the Clinical tab
    And  I save and exit
    And  I navigate to the morbidity event edit page
    And  I fill in "morbidity_event[interested_party][treatments][treatment_date] before?" with "treatment before"
    And  I save and exit 
    Then I should see "treatment before"


  Scenario: Editing a CMR with repeater core forms applied, save form answers with invalid data.
    Given a morbidity event with with a form with repeating core fields
    When I navigate to the morbidity event edit page
    And  I navigate to the Clinical tab 
    And  I fill in "Date of treatment" with an invalid date
    And  I fill in "morbidity_event[interested_party][treatments][treatment_date] before?" with "treatment repeaters work with errors too"
    And  I click the Treatment Save link
    Then I should see "Date of treatment must be on or before"
    And  I should see "treatment repeaters work with errors too"
    And  I should not see "successfully updated"
