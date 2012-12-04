Feature: Form fields for repeating core sections.

  To provide users with greater control over data collections
  I want to be able to add form fields to repeating core sections.
 
  Background:
    Given I am logged in as a super user

  # Coresponds with #1 from original email
  Scenario: Creating CMR with no core forms are applied, save multiple hospitalizations.
    When I navigate to the new morbidity event page and start a simple event
    And  I navigate to the Clinical tab
    Then I should see a link to "Add a Hospitalization Facility"
    Then I should not see hospitalization save and discard buttons

    When I enter the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
      | Alta View Hospital        |
      | American Fork Hospital    |
    And I save and continue
    And I navigate to the Clinical tab
    And I should see a link to "Add a Hospitalization Facility"
    Then I should not see hospitalization save and discard buttons
    When I save and exit
    And I should see the following in order:
      | Allen Memorial Hospital |
      | Alta View Hospital      |
      | American Fork Hospital  |




  # Coresponds with #2 from original email
  Scenario: Creating a CMR with repeater core forms applied, save multiple hospitalizations.
    Given a published form with repeating core fields for a morbidity event

    When I navigate to the new morbidity event page and start a event with the form's disease
    And  I navigate to the Clinical tab
    Then I should not see hospitalization save and discard buttons
    And  I should see a link to "Add a Hospitalization Facility"

    When I enter the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
      | Alta View Hospital        |
      | American Fork Hospital    |
    And I save and continue
    And I navigate to the morbidity event edit page
    Then I should see all of the repeater core field config questions for 3 hospitalization
    And I save and exit
    Then I should see all of the repeater core field config questions for 3 hospitalization



  # Coresponds with #3 from original email
  Scenario: Editing CMR with no core forms are applied, save multiple hospitalizations automatically.
    Given a basic morbidity event exists

    When I navigate to the morbidity event edit page
    Then I should not see a link to "Add a Hospitalization Facility"
    And  I should see hospitalization save and discard buttons

    When I enter the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
      | Alta View Hospital        |
      | American Fork Hospital    |
    And I save and continue
    And I navigate to the morbidity event show page
    Then I should see the following in order:
      | Allen Memorial Hospital |
      | Alta View Hospital      |
      | American Fork Hospital  |
    And I navigate to the morbidity event edit page
    And I navigate to the Clinical tab
    And I should see a link to "Add a Hospitalization Facility"
    And I should not see hospitalization save and discard buttons



  # Coresponds with #4 from original email
  Scenario: Editing a CMR with repeater core forms applied and one hospitalization, save/discard/add buttons should work as expected.
    Given a assessment event with with a form with repeating core fields and hospitalizations

    When I navigate to the assessment event edit page
    And  I navigate to the Clinical tab
    Then I should see 0 blank hospitalization form
    Then I should not see hospitalization save and discard buttons
    And  I should see a link to "Add a Hospitalization Facility"
    
    When I click the "Add a Hospitalization Facility" link and don't wait
    Then I should see hospitalization save and discard buttons
    And  I should not see a link to "Add a Hospitalization Facility"

    When I discard the unsaved hospitalization
    Then I should see a link to "Add a Hospitalization Facility"
    Then I should not see hospitalization save and discard buttons


  # Coresponds with #5 from original email
  Scenario: Editing a CMR with repeater core forms applied and zero hospitalizations, save/discard/add buttons should work as expected.
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Clinical tab
    Then I should see 1 blank hospitalization form
    Then I should see hospitalization save and discard buttons
    And  I should not see a link to "Add a Hospitalization Facility"
    
    When I discard the unsaved hospitalization
    Then I should see a link to "Add a Hospitalization Facility"
    Then I should not see hospitalization save and discard buttons

    When I click the "Add a Hospitalization Facility" link and don't wait
    Then I should see hospitalization save and discard buttons
    And  I should not see a link to "Add a Hospitalization Facility"


  # Coresponds with #6 from original email
  Scenario: Editing a CMR with repeater core forms applied, save a hospitalization with form data.
    Given a morbidity event with with a form with repeating core fields

    When I navigate to the morbidity event edit page
    And  I navigate to the Clinical tab
    And  I enter the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
    And I fill in "morbidity_event[hospitalization_facilities][secondary_entity_id] before?" with "entity before"
    And I fill in "morbidity_event[hospitalization_facilities][secondary_entity_id] after?" with "entity after"
    And I fill in "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date] before?" with "admission before"
    And I fill in "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date] after?" with "admission after"
    And I fill in "morbidity_event[hospitalization_facilities][hospitals_participation][discharge_date] before?" with "discharge before"
    And I fill in "morbidity_event[hospitalization_facilities][hospitals_participation][discharge_date] after?" with "discharge after"
    And I fill in "morbidity_event[hospitalization_facilities][hospitals_participation][medical_record_number] before?" with "medical before"
    And I fill in "morbidity_event[hospitalization_facilities][hospitals_participation][medical_record_number] after?" with "medical after"
    And  I click the Hospitalization Save link
    
    Then I should not see hospitalization save and discard buttons
    And  I should see a link to "Add a Hospitalization Facility"

    When I save and continue
    And I navigate to the morbidity event show page
    Then I should see "Allen Memorial Hospital"
    And  I should see "entity before"
    And  I should see "entity after"
    And  I should see "admission before"
    And  I should see "admission after"
    And  I should see "discharge before"
    And  I should see "discharge after"
    And  I should see "medical before"
    And  I should see "medical after"

    When I print the event
    Then I should see "Allen Memorial Hospital"
    And  I should see "entity before"
    And  I should see "entity after"
    And  I should see "admission before"
    And  I should see "admission after"
    And  I should see "discharge before"
    And  I should see "discharge after"
    And  I should see "medical before"
    And  I should see "medical after"



  # Coresponds with #7 with original email
  Scenario: Editing a CMR with repeater core forms applied, create and then discard a hospitalization.
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Clinical tab
    And  I enter the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
    And  I discard the unsaved hospitalization
    
    Then I should not see hospitalization save and discard buttons
    And  I should see a link to "Add a Hospitalization Facility"

    When I save and continue
    And I navigate to the morbidity event show page
 
    Then I should not see "Allen Memorial Hospital"
    
  # Coresponds with #8 from original email
  Scenario: Adding forms should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date] before?"

    When I click the "Add/Remove forms for this event" link
    And I check the form for addition
    And I click the "Add Forms" button

    When I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date] before?"

  # Coresponds with #9 from original email
  Scenario: Removing forms should remove fields for repeating core sections 
    Given a assessment event with with a form with repeating core fields and hospitalizations

    When I navigate to the assessment event edit page
    Then I should see a label "assessment_event[hospitalization_facilities][hospitals_participation][admission_date] before?"

    When I click the "Add/Remove forms for this event" link
    And I check the form for removal
    And I click and confirm the "Remove Forms" button

    When I navigate to the assessment event edit page
    Then I should not see a label "assessment_event[hospitalization_facilities][hospitals_participation][admission_date] before?"



  # Coresponds with #10 from original email
  Scenario: Adding forms after changing diseases should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date] before?"

    When I change the disease to match the published form
    And  I save and continue
    And  I check the form for addition
    And  I click and confirm the "Change Forms" button
    And  I navigate to the morbidity event edit page
    And  I navigate to the Clinical tab
    Then I should see a label "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date] before?"

  # Coresponds with #11 from original email
  Scenario: Removing forms after changing disease should remove fields for repeating core sections 
    Given a morbidity event with with a form with repeating core fields and hospitalizations

    When I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date] before?"

    When I change the disease to not match the published form
    And  I save and continue
    And  I check the form for removal
    And  I click and confirm the "Change Forms" button
    And  I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date] before?"

  # Coresponds with #12 from original email
  Scenario: When editing a CMR, unsaved hospitalizations are saved automatically with the event, even when user is on another tab
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Clinical tab
    And  I enter the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
    And I navigate to the Demographic tab
    And  I save and continue
    And  I navigate to the assessment event show page
    Then I should see "Allen Memorial Hospital"


  # Coresponds with email from Nov 20, 2012
  Scenario: Editing CMR with repeating core forms are applied, save multiple hospitalizations individually.
    Given   a morbidity event with with a form with repeating core fields

    When I navigate to the morbidity event edit page
    When I enter the following hospitalizations: 
      | name                      | admission_date    |
      | Allen Memorial Hospital   | November 20, 2012 |
    And  I click the Hospitalization Save link
    When I enter a second hospitalization: 
      | name                      | admission_date    |
      | Alta View Hospital        | November 19, 2012 |
    And  I click the Hospitalization Save link
    Then I should see the following in order:
    | Allen Memorial Hospital |
    | November 20, 2012       |
    | Alta View Hospital      |
    | November 19, 2012       |


  Scenario: Creating a CMR with repeater core forms applied, save multiple hospitalizations with form answers.
    Given a published form with repeating core fields for a morbidity event

    When I navigate to the new morbidity event page and start a event with the form's disease
    And  I navigate to the Clinical tab
    Then I should not see hospitalization save and discard buttons
    And  I should see a link to "Add a Hospitalization Facility"

    When I enter the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
    And  I save and continue
    Then I should see "Allen Memorial Hospital"

    When I navigate to the morbidity event edit page
    And  I fill in "morbidity_event[hospitalization_facilities][secondary_entity_id] before?" with "entity before"
    And  I save and continue 
    Then I should see "entity before"
 
  Scenario: Editing a CMR with repeater core forms applied, save hospitalization with invalid data.
    Given a morbidity event with with a form with repeating core fields
    When I navigate to the morbidity event edit page
    When I enter the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
    And  I fill in "Admission date" with an invalid date
    And  I fill in "morbidity_event[hospitalization_facilities][secondary_entity_id] before?" with "form fields work even with errors"
    And  I click the Hospitalization Save link
    Then I should see "Admission date must be on or before"
    And  I should see "form fields work even with errors"
   
    When I fill in "Admission date" with a valid date 
    And  I click the Hospitalization Save link
    Then I should not see "Admission date must be on or before"
    And  I should see "form fields work even with errors"

    When I enter a second hospitalization with an invalid admission date and form data
    And  I click the Hospitalization Save link
    Then I should see "Admission date must be on or before"
    And  I should see the form data entered for the second hospitalization

