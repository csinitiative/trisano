Feature: Form metadata is visible to form builders

  So as to provide better visibility into a form's usage
  As a form builder
  I want to be able to see form metadata

  Scenario: Viewing form metadata
    Given I am logged in as a super user
    And a published form exists with the name Metadata Form (meta_data_form) for a Morbidity event with any disease
    And that form has one question on the default view

    When I navigate to the form detail view

    Then I should be able to see how many elements there are on the master copy
    And I should be able to see how many questions there are on the master copy
    Then I should be able to see how many elements there are on the published version
    And I should be able to see how many questions there are on the published version

