Feature: Form fields for repeating core sections.

  To provide users with greater control over data collections
  I want to be able to add form fields to repeating core sections.
 
  Background:
    Given I am logged in as a super user
    And   I have required repeater core field prerequisites


  Scenario: All repeaters are availble.
    Given   a encounter event with with a form with repeating core fields 
    
    When    I navigate to the form's builder page
    Then    I should see "Treatment | Treatment given"
    And     I should see "Treatment | Treatment"
    And     I should see "Treatment | Date of treatment"
    And     I should see "Treatment | Date treatment stopped"
    And     I should see "Lab results | Accession number"
    And     I should see "Lab results | Test type"
    And     I should see "Lab results | Organism"
    And     I should see "Lab results | Test result"
    And     I should see "Lab results | Result value"
    And     I should see "Lab results | Units"
    And     I should see "Lab results | Reference range"
    And     I should see "Lab results | Test status"
    And     I should see "Lab results | Specimen source"
    And     I should see "Lab results | Collection date"
    And     I should see "Lab results | Lab test date"
    And     I should see "Lab results | Specimen sent to state lab"
    And     I should see "Lab results | Comment"
   

  Scenario: Empty repeaters are ignored.
    Given   a encounter event with with a form with repeating core fields 

    When    I navigate to the encounter event edit page
    Then    I should see all of the repeater core field config questions
    And     I save and exit
    And     I should see "successfully updated"
    And     I should not see any core field config repeating question


  Scenario: Answer all repeaters.
    Given   a encounter event with with a form with repeating core fields 

    When    I navigate to the encounter event edit page
    And     I answer all core field config repeating questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see all core field config repeating answers

    When    I save and exit
    Then    I should see "successfully updated"
    And     I should see all core field config repeating answers


  Scenario: Answer all repeaters after adding a form.
    Given   a basic encounter event exists
    And     a published form with repeating core fields for a encounter event

    When    I navigate to the encounter event edit page
    Then    I should not see any core field config repeating question

    When    I click the "Add/Remove forms for this event" link
    And     I check the form for addition
    And     I click the "Add Forms" button
    And     I navigate to the encounter event edit page
    Then    I should see all of the repeater core field config questions
    And     I answer all core field config repeating questions
    And     I save and continue
    Then    I should see "successfully updated"
    Then    I should see all core field config repeating answers

    When    I save and exit
    Then    I should see "successfully updated"
    Then    I should see all core field config repeating answers


  Scenario: Removing forms removes repeater answers. 
    Given   a encounter event with with a form with repeating core fields

    When    I navigate to the encounter event edit page
    Then    I should see all of the repeater core field config questions

    When    I click the "Add/Remove forms for this event" link
    And     I check the form for removal
    And     I click and confirm the "Remove Forms" button
    And     I navigate to the encounter event edit page
    Then    I should not see any core field config repeating question
