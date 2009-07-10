Features: Attaching documents to an Event.

  To support better documenting of cases
  Correspondence and images files can be attached to an event.


  Scenario: Delete an attachment from the add attachment screen
    Given I am logged in as a super user
    And a simple morbidity event in jurisdiction Davis County for last name Simpson
    And a file attachment named "test-attachment"

    When I navigate to the add attachments page
    And I wait for the page to load
    And I click and confirm the "Delete" link
    And I wait for the page to load
    
    Then I should not see "test-attachment" listed as an attachment

  Scenario: Delete an attachment from the event show screen
    Given I am logged in as a super user
    And a simple morbidity event in jurisdiction Davis County for last name Simpson
    And a file attachment named "test-attachment"

    When I navigate to the event show page
    And I click and confirm the attachment "Delete" link
    And I wait for the page to load
        
    Then I should not see "test-attachment" listed as an attachment

