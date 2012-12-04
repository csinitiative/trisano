Feature: Form fields for repeating core sections.

  To provide users with greater control over data collections
  I want to be able to add form fields to repeating core sections.
 
  Background:
    Given I am logged in as a super user

  # Coresponds with #1 from original email
  Scenario: Creating CMR with no core forms are applied, save multiple email addresses.
    When I navigate to the new morbidity event page and start a simple event
    And  I navigate to the Demographic tab
    Then I should see a link to "Add an Email Address"
    Then I should not see email address save and discard buttons

    When I enter the following email addresses: 
      | email         |
      | asdf@test.com |           
      | qwer@test.com |
    And I save and continue
    And I navigate to the morbidity event show page
    Then I should see "asdf@test.com"
    And  I should see "qwer@test.com"
    And  I navigate to the morbidity event edit page
    And  I navigate to the Demographic tab
    And  I should see a link to "Add an Email Address"
    And  I should not see email address save and discard buttons




  # Coresponds with #2 from original email
  Scenario: Creating a CMR with repeater core forms applied, save multiple email addresses.
    Given a published form with repeating core fields for a morbidity event

    When I navigate to the new morbidity event page and start a event with the form's disease
    And  I navigate to the Demographic tab
    Then I should not see email address save and discard buttons
    And  I should see a link to "Add an Email Address"

    When I enter the following email addresses: 
      | email         |
      | asdf@test.com |           
    And I save and continue
    And I navigate to the morbidity event edit page
    Then I should see all of the repeater core field config questions for each email address

    When I navigate to the morbidity event show page
    Then I should see all of the repeater core field config questions for each email address



  # Coresponds with #3 from original email
  Scenario: Editing CMR with no core forms are applied, save multiple email addresses.
    Given a basic assessment event exists

    When I navigate to the assessment event edit page
    Then I should not see a link to "Add an Email Address"
    And  I should see email address save and discard buttons

    When I enter the following email addresses: 
      | email         |
      | asdf@test.com |           
      | qwer@test.com |
    And I save and continue
    And I navigate to the assessment event show page
    Then I should see "asdf@test.com"
    And  I should see "qwer@test.com"
    And I navigate to the assessment event edit page
    And I navigate to the Demographic tab
    And I should see a link to "Add an Email Address"
    And I should not see email address save and discard buttons



  # Coresponds with #4 from original email
  Scenario: Editing a CMR with repeater core forms applied and one email address, save/discard/add buttons should work as expected.
    Given a assessment event with with a form with repeating core fields and email addresses

    When I navigate to the assessment event edit page
    And  I navigate to the Demographic tab
    Then I should see 0 blank email address form
    Then I should not see email address save and discard buttons
    And  I should see a link to "Add an Email Address"
    
    When I click the "Add an Email Address" link and don't wait
    Then I should see email address save and discard buttons
    And  I should not see a link to "Add an Email Address"

    When I discard the unsaved email address
    Then I should see a link to "Add an Email Address"
    Then I should not see email address save and discard buttons


  # Coresponds with #5 from original email
  Scenario: Editing a CMR with repeater core forms applied and zero email addresses, save/discard/add buttons should work as expected.
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Demographic tab
    Then I should see 1 blank email address form
    Then I should see email address save and discard buttons
    And  I should not see a link to "Add an Email Address"
    
    When I discard the unsaved email address
    Then I should see a link to "Add an Email Address"
    Then I should not see email address save and discard buttons

    When I click the "Add an Email Address" link and don't wait
    Then I should see email address save and discard buttons
    And  I should not see a link to "Add an Email Address"


  # Coresponds with #6 from original email
  Scenario: Editing a CMR with repeater core forms applied, save a email address with form data.
    Given a morbidity event with with a form with repeating core fields

    When I navigate to the morbidity event edit page
    And  I navigate to the Demographic tab
    And  I enter the following email addresses: 
      | email         |
      | asdf@test.com |           
    And I fill in "morbidity_event[interested_party][person_entity][email_addresses][email_address] before?" with "email before"
    And I fill in "morbidity_event[interested_party][person_entity][email_addresses][email_address] after?" with "email after"
    And  I click the Email Save link
    
    Then I should not see email address save and discard buttons
    And  I should see a link to "Add an Email Address"

    When I save and continue
    And I navigate to the morbidity event show page
    Then I should see "asdf@test.com"
    And  I should see "email before"
    And  I should see "email after"

    When I print the event
    Then I should see "asdf@test.com"
    And  I should see "email before"
    And  I should see "email after"

  # Coresponds with #7 with original email
  Scenario: Editing a CMR with repeater core forms applied, create and then discard a email address.
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Demographic tab
    And  I enter the following email addresses: 
      | email         |
      | asdf@test.com |           
    And  I discard the unsaved email address
    
    Then I should not see email address save and discard buttons
    And  I should see a link to "Add an Email Address"

    When I save and continue
    And I navigate to the morbidity event show page
 
    Then I should not see "asdf@test.com"
    
  # Coresponds with #8 from original email
  Scenario: Adding forms should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[interested_party][person_entity][email_addresses][email_address] before?"

    When I click the "Add/Remove forms for this event" link
    And I check the form for addition
    And I click the "Add Forms" button

    When I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[interested_party][person_entity][email_addresses][email_address] before?"

  # Coresponds with #9 from original email
  Scenario: Removing forms should remove fields for repeating core sections 
    Given a assessment event with with a form with repeating core fields and email addresses

    When I navigate to the assessment event edit page
    Then I should see a label "assessment_event[interested_party][person_entity][email_addresses][email_address] before?"

    When I click the "Add/Remove forms for this event" link
    And I check the form for removal
    And I click and confirm the "Remove Forms" button

    When I navigate to the assessment event edit page
    Then I should not see a label "assessment_event[interested_party][person_entity][email_addresses][email_address] before?"



  # Coresponds with #10 from original email
  Scenario: Adding forms after changing diseases should create fields for repeating core sections 
    Given a basic morbidity event exists
    And a published form with repeating core fields for a morbidity event

    When I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[interested_party][person_entity][email_addresses][email_address] before?"

    When I change the disease to match the published form
    And  I save and continue
    And  I check the form for addition
    And  I click and confirm the "Change Forms" button
    And  I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[interested_party][person_entity][email_addresses][email_address] before?"

  # Coresponds with #11 from original email
  Scenario: Removing forms after changing disease should remove fields for repeating core sections 
    Given a morbidity event with with a form with repeating core fields and email addresses

    When I navigate to the morbidity event edit page
    Then I should see a label "morbidity_event[interested_party][person_entity][email_addresses][email_address] before?"

    When I change the disease to not match the published form
    And  I save and continue
    And  I check the form for removal
    And  I click and confirm the "Change Forms" button
    And  I navigate to the morbidity event edit page
    Then I should not see a label "morbidity_event[interested_party][person_entity][email_addresses][email_address] before?"

  # Coresponds with #12 from original email
  Scenario: When editing a CMR, unsaved email addresses are saved automatically with the event, even when the user is on another tab
    Given   a assessment event with with a form with repeating core fields

    When I navigate to the assessment event edit page
    And  I navigate to the Demographic tab
    And  I enter the following email addresses: 
      | email         |
      | asdf@test.com |           
    And I navigate to the Clinical tab
    And  I save and continue
    And  I navigate to the assessment event show page
    Then I should see "asdf@test.com"



  # Coresponds with email from Nov 20, 2012
  Scenario: Editing CMR with repeating core forms are applied, save multiple email addresses individually.
    Given   a morbidity event with with a form with repeating core fields

    When I navigate to the morbidity event edit page
    And  I navigate to the Demographic tab
    And  I enter the following email addresses: 
      | email         |
      | asdf@test.com |           
    And  I click the Email Save link
    When I enter a second email address: 
      | email         |
      | qwer@test.com |           
    And  I click the Email Save link
    Then I should see the following in order:
    | asdf@test.com |
    | qwer@test.com |


  Scenario: Creating a CMR with repeater core forms applied, save form answers.
    Given a published form with repeating core fields for a morbidity event

    When I navigate to the new morbidity event page and start a event with the form's disease
    And  I navigate to the Demographic tab

    When I enter the following email addresses: 
      | email         |
      | asdf@test.com |           
    And  I save and continue
    Then I should see "asdf@test.com"

    When I navigate to the morbidity event edit page
    And  I fill in "morbidity_event[interested_party][person_entity][email_addresses][email_address] before?" with "email before"
    And  I save and continue 
    Then I should see "email before"


  Scenario: Editing a CMR with repeater core forms applied, save form answers with invalid data.
    Given a morbidity event with with a form with repeating core fields
    When I navigate to the morbidity event edit page
   
    When I enter the following email addresses: 
      | email         |
      | asdf          |           
    And  I fill in "morbidity_event[interested_party][person_entity][email_addresses][email_address] before?" with "email address repeaters work with errors too"
    And  I click the Email Save link
    Then I should see "Email address format is invalid"
    And  I should see "email address repeaters work with errors too"
