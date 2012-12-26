Feature: Form fields for repeating core sections.

  To provide users with greater control over data collections
  I want to be able to add form fields to repeating core sections.
 
  Background:
    Given I am logged in as a super user
    And   I have required repeater core field prerequisites


  Scenario: All repeaters are availble.
    Given   a published form with repeating core fields for a morbidity and assessment event
    
    When    I navigate to the form's builder page
    Then    I should see "Hospitalization | Health facility"
    And     I should see "Hospitalization | Admission date"
    And     I should see "Hospitalization | Discharge date"
    And     I should see "Hospitalization | Medical record number"
    And     I should see "Treatment | Treatment given"
    And     I should see "Treatment | Treatment"
    And     I should see "Treatment | Date of treatment"
    And     I should see "Treatment | Date treatment stopped"
    And     I should see "Patient telephone"
    And     I should see "Patient email address"
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
    Given   a assessment event with a morbidity and assessment event form with repeating core fields 

    When    I navigate to the assessment event edit page
    Then    I should see 1 instances of the repeater core field config questions
    And     I save and exit
    And     I should see "successfully updated"
    And     I should see 0 instances of the repeater core field config questions


  Scenario: Empty repeaters are ignored.
    Given   a morbidity event with a morbidity and assessment event form with repeating core fields 

    When    I navigate to the morbidity event edit page
    Then    I should see 1 instances of the repeater core field config questions
    And     I save and exit
    And     I should see "successfully updated"
    And     I should see 0 instances of the repeater core field config questions


  Scenario: Answer multiple repeaters.
    Given   a morbidity event with a morbidity and assessment event form with repeating core fields

    When    I navigate to the morbidity event edit page
    And     I create 1 new instances of all morbidity and assessment event repeaters
    Then    I should see 2 instances of the repeater core field config questions

    When    I answer 2 instances of all repeater questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I save and exit
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I print the morbidity event
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions
   

  Scenario: Answer multiple repeaters.
    Given   a assessment event with a morbidity and assessment event form with repeating core fields

    When    I navigate to the assessment event edit page
    And     I create 1 new instances of all morbidity and assessment event repeaters
    Then    I should see 2 instances of the repeater core field config questions

    When    I answer 2 instances of all repeater questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I save and exit
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I print the assessment event
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

  Scenario: Answer all repeaters after adding a form.
    Given   a basic assessment event exists
    And     a published form with repeating core fields for a morbidity and assessment event

    When    I navigate to the assessment event edit page
    Then    I should see 0 instances of the repeater core field config questions

    When    I change the disease to match the published form
    And     I save and continue
    Then    I should see "successfully updated"

    When    I click the "Cancel" button
    And     I click the "Add/Remove forms for this event" link
    And     I check the form for addition
    And     I click the "Add Forms" button
    And     I navigate to the assessment event edit page
    Then    I should see 1 instances of the repeater core field config questions

    When    I create 1 new instances of all assessment event repeaters
    And     I answer 2 instances of all repeater questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I save and exit
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I print the assessment event
    Then    I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions


  Scenario: Answer all repeaters after adding a form.
    Given   a basic morbidity event exists
    And     a published form with repeating core fields for a morbidity and assessment event

    When    I navigate to the morbidity event edit page
    Then    I should see 0 instances of the repeater core field config questions

    When    I change the disease to match the published form
    And     I save and continue
    Then    I should see "successfully updated"

    When    I click the "Cancel" button
    And     I click the "Add/Remove forms for this event" link
    And     I check the form for addition
    And     I click the "Add Forms" button
    And     I navigate to the morbidity event edit page
    Then    I should see 1 instances of the repeater core field config questions

    When    I create 1 new instances of all morbidity event repeaters
    And     I answer 2 instances of all repeater questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I save and exit
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I print the morbidity event
    Then    I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions


  Scenario: Removing forms removes repeater answers. 
    Given   a assessment event with a morbidity and assessment event form with repeating core fields

    When    I navigate to the assessment event edit page
    Then    I should see 1 instances of the repeater core field config questions

    When    I create 1 new instances of all assessment event repeaters
    And     I answer 2 instances of all repeater questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I click the "Add/Remove forms for this event" link
    And     I check the form for removal
    And     I click and confirm the "Remove Forms" button
    And     I navigate to the assessment event edit page
    Then    I should see 0 instances of the repeater core field config questions
    And     I should see 0 instances of answers to the repeating core field config questions


  Scenario: Removing forms removes repeater answers. 
    Given   a morbidity event with a morbidity and assessment event form with repeating core fields

    When    I navigate to the morbidity event edit page
    Then    I should see 1 instances of the repeater core field config questions

    When    I create 1 new instances of all morbidity event repeaters
    And     I answer 2 instances of all repeater questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I click the "Add/Remove forms for this event" link
    And     I check the form for removal
    And     I click and confirm the "Remove Forms" button
    And     I navigate to the morbidity event edit page
    Then    I should see 0 instances of the repeater core field config questions
    And     I should see 0 instances of answers to the repeating core field config questions


  Scenario: Answer all repeaters after adding forms after changing diseases. 
    Given   a basic assessment event exists
    And     a published form with repeating core fields for a morbidity and assessment event

    When    I navigate to the assessment event edit page
    Then    I should see 0 instances of the repeater core field config questions

    When    I change the disease to match the published form
    And     I save and continue
    Then    I should see "successfully updated"

    And     I click and confirm the "Change Forms" button
    Then    I should see "successfully updated"
    And     I should see 1 instances of the repeater core field config questions

    When    I create 1 new instances of all assessment event repeaters
    And     I answer 2 instances of all repeater questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I save and exit
    Then    I should see "successfully updated"
    Then    I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I print the assessment event
    Then    I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions


  Scenario: Answer all repeaters after adding forms after changing diseases. 
    Given   a basic morbidity event exists
    And     a published form with repeating core fields for a morbidity and assessment event

    When    I navigate to the morbidity event edit page
    Then    I should see 0 instances of the repeater core field config questions

    When    I change the disease to match the published form
    And     I save and continue
    Then    I should see "successfully updated"

    And     I click and confirm the "Change Forms" button
    Then    I should see "successfully updated"
    And     I should see 1 instances of the repeater core field config questions

    When    I create 1 new instances of all morbidity event repeaters
    And     I answer 2 instances of all repeater questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I save and exit
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I print the morbidity event
    Then    I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions


  Scenario: Removing forms after changing disease removes repeater answers. 
    Given   a assessment event with a morbidity and assessment event form with repeating core fields

    When    I navigate to the assessment event edit page
    Then    I should see 1 instances of the repeater core field config questions

    When    I create 1 new instances of all morbidity event repeaters
    And     I answer 2 instances of all repeater questions
    And     I save and continue
    And     I change the disease to not match the published form
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I check the form for removal
    And     I click and confirm the "Change Forms" button
    Then    I should see "successfully updated"
    And     I should see 0 instances of the repeater core field config questions
    And     I should see 0 instances of answers to the repeating core field config questions
   

  Scenario: Removing forms after changing disease removes repeater answers. 
    Given   a morbidity event with a morbidity and assessment event form with repeating core fields

    When    I navigate to the morbidity event edit page
    Then    I should see 1 instances of the repeater core field config questions

    When    I create 1 new instances of all morbidity event repeaters
    And     I answer 2 instances of all repeater questions
    And     I save and continue
    And     I change the disease to not match the published form
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater core field config questions
    And     I should see 2 instances of answers to the repeating core field config questions

    When    I check the form for removal
    And     I click and confirm the "Change Forms" button
    Then    I should see "successfully updated"
    And     I should see 0 instances of the repeater core field config questions
    And     I should see 0 instances of answers to the repeating core field config questions
