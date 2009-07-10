Features: Attaching documents to an Event.

  To support better documenting of cases
  Correspondence and images files can be attached to an event.

  Scenario: Attach a file to a Morbidity report
    Given I am logged in as a super user
    And a simple morbidity event in jurisdiction Davis County for last name Simpson

    When I navigate to the add attachments page
    And I upload the "test-attachment" file
    And I press "Create"

    Then I should see "test-attachment" listed as an attachment
