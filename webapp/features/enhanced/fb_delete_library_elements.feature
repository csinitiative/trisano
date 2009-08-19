Feature: Form builders can delete questions, value sets and groups from the library

  To make it easier to manage all of the possible elements in library and prevent errors building forms
  A form builder needs to be able to delete deprecated or incorrect elements from the library.

  @clean_forms @clean_form_elements
  Scenario: Delete a question from the library
    Given I am logged in as a super user
    And a Morbidity event form exists
    And the question "Example Question?" is in the library
    When I go to the Builder interface for the form
    And I click the "Open library" link and wait to see "Library Administration"
    And I delete the question element
    Then the text "Example Question?" should disappear

  @clean_forms @clean_form_elements
  Scenario: Delete a grouped question from the library
    Given I am logged in as a super user
    And a Morbidity event form exists
    And the question "Example Question?" in group "Example Group" is in the library
    When I go to the Builder interface for the form
    And I click the "Open library" link and wait to see "Example Group"
    And I delete the question element
    Then the text "Example Question?" should disappear

  @clean_forms @clean_form_elements
  Scenario: Delete a value set from the library
    Given I am logged in as a super user
    And a Morbidity event form exists
    And a value set named "Example Value Set" exists in the library with these values:
      | value_name | code |
      | Yes        |  1   |
      | No         |  2   |
      | Maybe      |  9   |
    When I go to the Builder interface for the form
    And I click the "Open library" link and wait to see "Library Administration"
    And I click the "Value sets" link and wait to see "Example Value Set"
    And I delete the value set element
    Then the text "Example Value Set" should disappear
