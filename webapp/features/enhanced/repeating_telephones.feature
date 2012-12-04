Feature: Form fields for repeating core sections.

  To provide users with greater control over data collections
  I want to be able to add form fields to repeating core sections.
 
  Background:
    Given I am logged in as a super user

  # Coresponds with #1 from original email
  Scenario: Creating CMR with no core forms are applied, save multiple telephone numbers.
    When I navigate to the new morbidity event page and start a simple event
    And  I navigate to the Demographic tab
    Then I should see a link to "Add a Telephone"
    Then I should not see telephone save and discard buttons

    When I enter the following telephone numbers: 
      | type  | area code | number    |
      | Home  | 555       | 555-5555  |           
      | Work  | 777       | 777-7777  |
    And I save and exit
    Then I should see "Home: (555) 555-5555"
    And  I should see "Work: (777) 777-7777"
    And  I navigate to the morbidity event edit page
    And  I navigate to the Demographic tab
    And  I should see a link to "Add a Telephone"
    And  I should not see telephone save and discard buttons




  # Coresponds with #2 from original email
  Scenario: Creating a CMR with repeater core forms applied, save multiple telephone numbers.
    Given a published form with repeating core fields for a morbidity event

    When I navigate to the new morbidity event page and start a event with the form's disease
    And  I navigate to the Demographic tab
    Then I should not see telephone save and discard buttons
    And  I should see a link to "Add a Telephone"

    When I enter the following telephone numbers: 
      | type  | area code | number    |
      | Home  | 555       | 555-5555  |           
      | Work  | 777       | 777-7777  |
    And I save and continue
    Then I should see all of the repeater core field config questions for 2 telephone number
    And I save and exit
    Then I should see all of the repeater core field config questions for 2 telephone number



  # Coresponds with #3 from original email
  Scenario: Editing CMR with no core forms are applied, save multiple telephone numbers.
    Given a basic assessment event exists

    When I navigate to the assessment event edit page
    Then I should not see a link to "Add a Telephone"
    And  I should see telephone save and discard buttons

    When I enter the following telephone numbers: 
      | type  | area code | number    |
      | Home  | 555       | 555-5555  |           
      | Work  | 777       | 777-7777  |
    And I save and exit
    Then I should see "Home: (555) 555-5555"
    And  I should see "Work: (777) 777-7777"
    And I navigate to the assessment event edit page
    And I navigate to the Demographic tab
    And I should see a link to "Add a Telephone"
    And I should not see telephone save and discard buttons



  # Coresponds with #4 from original email
  Scenario: Editing a CMR with repeater core forms applied and one telephone, save/discard/add buttons should work as expected.
    Given a assessment event with with a form with repeating core fields and telephones

    When I navigate to the assessment event edit page
    And  I navigate to the Demographic tab
    Then I should see 0 blank telephone form
    Then I should not see telephone save and discard buttons
    And  I should see a link to "Add a Telephone"
    
    When I click the "Add a Telephone" link and don't wait
    Then I should see telephone save and discard buttons
    And  I should not see a link to "Add a Telephone"

    When I discard the unsaved telephone
    Then I should see a link to "Add a Telephone"
    Then I should not see telephone save and discard buttons


  # Coresponds with #5 from original email
  Scenario: Editing a CMR with repeater core forms applied and zero telephones, save/discard/add buttons should work as expected.
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Demographic tab
    Then I should see 1 blank telephone form
    Then I should see telephone save and discard buttons
    And  I should not see a link to "Add a Telephone"
    
    When I discard the unsaved telephone
    Then I should see a link to "Add a Telephone"
    Then I should not see telephone save and discard buttons

    When I click the "Add a Telephone" link and don't wait
    Then I should see telephone save and discard buttons
    And  I should not see a link to "Add a Telephone"


  # Coresponds with #6 from original email
  Scenario: Editing a CMR with repeater core forms applied, save a telephone with form data.
    Given a morbidity event with with a form with repeating core fields

    When I navigate to the morbidity event edit page
    And  I navigate to the Demographic tab
    And  I enter the following telephone numbers: 
      | type  | area code | number   |
      | Work  | 555       | 555-5555 |
    And I fill in "morbidity_event[interested_party][person_entity][telephones][patient_telephone] before?" with "patient phone before"
    And I fill in "morbidity_event[interested_party][person_entity][telephones][patient_telephone] after?" with "patient phone after"
    And  I click the Telephone Save link
    
    Then I should not see telephone save and discard buttons
    And  I should see a link to "Add a Telephone"

    When I save and exit
    Then I should see "Work: (555) 555-5555"
    And  I should see "patient phone before"
    And  I should see "patient phone after"

    When I print the event
    Then I should see "Work: (555) 555-5555"
    And  I should see "patient phone before"
    And  I should see "patient phone after"

  # Coresponds with #7 with original email
  Scenario: Editing a CMR with repeater core forms applied, create and then discard a telephone.
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Demographic tab
    And  I enter the following telephone numbers: 
      | type  | area code | number   |
      | Work  | 555       | 555-5555 |
    And  I discard the unsaved telephone
    
    Then I should not see telephone save and discard buttons
    And  I should see a link to "Add a Telephone"

    When I save and exit
    Then I should not see "Work: (555) 555-5555"
    
  # Coresponds with #8 from original email
  Scenario: Adding forms should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[interested_party][person_entity][telephones][patient_telephone] before?"

    When I click the "Add/Remove forms for this event" link
    And I check the form for addition
    And I click the "Add Forms" button

    When I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[interested_party][person_entity][telephones][patient_telephone] before?"

  # Coresponds with #9 from original email
  Scenario: Removing forms should remove fields for repeating core sections 
    Given a assessment event with with a form with repeating core fields and telephones

    When I navigate to the assessment event edit page
    Then I should see a label "assessment_event[interested_party][person_entity][telephones][patient_telephone] before?"

    When I click the "Add/Remove forms for this event" link
    And I check the form for removal
    And I click and confirm the "Remove Forms" button

    When I navigate to the assessment event edit page
    Then I should not see a label "assessment_event[interested_party][person_entity][telephones][patient_telephone] before?"



  # Coresponds with #10 from original email
  Scenario: Adding forms after changing diseases should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[interested_party][person_entity][telephones][patient_telephone] before?"

    When I change the disease to match the published form
    And  I save and continue
    And  I check the form for addition
    And  I click and confirm the "Change Forms" button
    And  I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[interested_party][person_entity][telephones][patient_telephone] before?"

  # Coresponds with #11 from original email
  Scenario: Removing forms after changing disease should remove fields for repeating core sections 
    Given a morbidity event with with a form with repeating core fields and telephones

    When I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[interested_party][person_entity][telephones][patient_telephone] before?"

    When I change the disease to not match the published form
    And  I save and continue
    And  I check the form for removal
    And  I click and confirm the "Change Forms" button
    And  I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[interested_party][person_entity][telephones][patient_telephone] before?"

  # Coresponds with #12 from original email
  Scenario: When editing a CMR, unsaved telephones are saved automatically with the event, even when the user is on another tab
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Demographic tab
    And  I enter the following telephone numbers: 
      | type  | area code | number   |
      | Work  | 555       | 555-5555 |
    And I navigate to the Clinical tab
    And  I save and exit
    Then I should see "Work: (555) 555-5555"



  # Coresponds with email from Nov 20, 2012
  Scenario: Editing CMR with repeating core forms are applied, save multiple telephones individually.
    Given   a morbidity event with with a form with repeating core fields

    When I navigate to the morbidity event edit page
    And  I navigate to the Demographic tab
    And  I enter the following telephone numbers: 
      | type  | area code | number   |
      | Work  | 555       | 555-5555 |
    And  I click the Telephone Save link
    When I enter a second telephone number: 
      | type  | area code | number   |
      | Home  | 666       | 666-6666 |
    And  I click the Telephone Save link
    Then I should see the following in order:
    | 5555555 |
    | 6666666 |


  Scenario: Creating a CMR with repeater core forms applied, save form answers.
    Given a published form with repeating core fields for a morbidity event

    When I navigate to the new morbidity event page and start a event with the form's disease
    And  I navigate to the Demographic tab

    When I enter the following telephone numbers: 
      | type  | area code | number   |
      | Work  | 555       | 555-5555 |
    And  I save and exit
    Then I should see "Work: (555) 555-5555"

    When I navigate to the morbidity event edit page
    And  I fill in "morbidity_event[interested_party][person_entity][telephones][patient_telephone] before?" with "patient tele before"
    And  I save and exit 
    Then I should see "patient tele before"


  Scenario: Editing a CMR with repeater core forms applied, save form answers with invalid data.
    Given a morbidity event with with a form with repeating core fields
    When I navigate to the morbidity event edit page
   
    When I enter the following telephone numbers: 
      | type  | area code | number   |
      | Work  | 555       | 555      |
    And  I fill in "morbidity_event[interested_party][person_entity][telephones][patient_telephone] before?" with "telephone repeaters work with errors too"
    And  I click the Telephone Save link
    Then I should see "Phone number must not be blank and must be 7 digits with an optional dash"
    And  I should see "telephone repeaters work with errors too"
