Features: Working with events with a deactivated disease

  Scenario: Editing a disease with a deactivated disease
    Given I am logged in as a super user
      And a morbidity event exists with a deactivated disease
    When I am on the morbidity event edit page
      Then the deactivated disease should be selected in the disease select list
    When I fill in "Last name" with "Newlast"
      And I save and continue
    Then the deactivated disease should still be set on the event
      And I should see "Newlast"

