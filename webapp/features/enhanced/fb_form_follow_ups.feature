Feature: Form form field follow ups

  To allow for a more relevant event form
  An investigator should see form field follow ups

  Scenario: Morbidity event form field follow ups
    Given I am logged in as a super user
    And a morbidity event form exists
    And that form has follow ups configured for all configured form fields
    And that form is published
    And a morbidity event exists with a disease that matches the form
    And I am on the morbidity event edit page
    And I should not see any of the form field follow up questions

    When I answer all of the form field follow ups with a matching condition
    Then I should see all of the form field follow up questions

    When I answer all form field follow up questions
    And I save and continue
    Then I should see all of the form field follow up questions
    And I should see all form field follow up answers

    When I am on the morbidity event edit page
    And I answer all of the form field follow ups with a non-matching condition
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

    When I save and continue
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

  Scenario: Assessment event form field follow ups
    Given I am logged in as a super user
    And a assessment event form exists
    And that form has follow ups configured for all configured form fields
    And that form is published
    And a assessment event exists with a disease that matches the form
    And I am on the assessment event edit page
    And I should not see any of the form field follow up questions

    When I answer all of the form field follow ups with a matching condition
    Then I should see all of the form field follow up questions

    When I answer all form field follow up questions
    And I save and continue
    Then I should see all of the form field follow up questions
    And I should see all form field follow up answers

    When I am on the assessment event edit page
    And I answer all of the form field follow ups with a non-matching condition
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

    When I save and continue
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

  Scenario: Contact event form field follow ups
    Given I am logged in as a super user
    And a contact event form exists
    And that form has follow ups configured for all configured form fields
    And that form is published
    And a contact event exists with a disease that matches the form
    And I am on the contact event edit page
    And I should not see any of the form field follow up questions

    When I answer all of the form field follow ups with a matching condition
    Then I should see all of the form field follow up questions

    When I answer all form field follow up questions
    And I save and continue
    Then I should see all of the form field follow up questions
    And I should see all form field follow up answers

    When I am on the contact event edit page
    And I answer all of the form field follow ups with a non-matching condition
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

    When I save and continue
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

  Scenario: Place event form field follow ups
    Given I am logged in as a super user
    And a place event form exists
    And that form has follow ups configured for all configured form fields
    And that form is published
    And a place event exists with a disease that matches the form
    And I am on the place event edit page
    And I should not see any of the form field follow up questions

    When I answer all of the form field follow ups with a matching condition
    Then I should see all of the form field follow up questions

    When I answer all form field follow up questions
    And I save and continue
    Then I should see all of the form field follow up questions
    And I should see all form field follow up answers

    When I am on the place event edit page
    And I answer all of the form field follow ups with a non-matching condition
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

    When I save and continue
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

  Scenario: Encounter event form field follow ups
    Given I am logged in as a super user
    And a encounter event form exists
    And that form has follow ups configured for all configured form fields
    And that form is published
    And a encounter event exists with a disease that matches the form
    And I am on the encounter event edit page
    And I should not see any of the form field follow up questions

    When I answer all of the form field follow ups with a matching condition
    Then I should see all of the form field follow up questions

    When I answer all form field follow up questions
    And I save and continue
    Then I should see all of the form field follow up questions
    And I should see all form field follow up answers

    When I am on the encounter event edit page
    And I answer all of the form field follow ups with a non-matching condition
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

    When I save and continue
    Then I should not see any of the form field follow up questions
    And I should not see any follow up answers

