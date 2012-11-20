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
    And I save the event
    And I navigate to the morbidity event show page
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
    And I save the event
    And I navigate to the morbidity event edit page
    Then I should see all of the repeater core field config questions for each telephone number

    When I navigate to the morbidity event show page
    Then I should see all of the repeater core field config questions for each telephone number



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
    And I save the event
    And I navigate to the assessment event show page
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

    When I save the event
    And I navigate to the morbidity event show page
    Then I should see "Work: (555) 555-5555"
    And  I should see "patient phone before"
    And  I should see "patient phone after"

    When I print the event
    Then I should see "Work: (555) 555-5555"
    And  I should see "patient phone before"
    And  I should see "patient phone after"
