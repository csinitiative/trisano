Feature: Morbidity event form core view configs

  To allow for a more relevant event form
  An investigator should see core view configs on a moridity form

  Scenario: Morbidity event core view configs
    Given I am logged in as a super user
    And a morbidity event form exists
    And that form has core view configs configured for all core views
    And that form is published
    And a morbidity event exists with a disease that matches the form
    When I am on the morbidity event edit page
    Then I should see all of the core view config questions

    When I answer all core view config questions
    And I save and continue
    Then I should see all of the core view config questions
    And I should see all core view config answers

  Scenario: Morbidity event repeating sections
    Given   I am logged in as a super user
    And     a morbidity event form exists
    And     that form has a repeating section configured in the default view with a question
    And     that form is published
    And     a morbidity event exists with a disease that matches the form

    When    I am on the morbidity event edit page
    And     I create 1 new instances of all section repeaters
    Then    I should see 2 instances of the repeater section questions

    When    I answer 2 instances of all repeater section questions
    And     I save and continue
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater section questions
    And     I should see 2 instances of answers to the repeating section questions

    When    I save and exit
    Then    I should see "successfully updated"
    And     I should see 2 instances of the repeater section questions
    And     I should see 2 instances of answers to the repeating section questions

    When    I print the assessment event
    And     I should see 2 instances of the repeater section questions
    And     I should see 2 instances of answers to the repeating section questions


