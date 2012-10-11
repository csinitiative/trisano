Feature: Managing forms on events

  Scenario: Update event forms should pop up after disease update
    Given I am logged in as a super user
    And a basic morbidity event exists
    And a form for "AIDS" is present
    When I navigate to the morbidity event edit page
    And I select "AIDS" from "Diseases"
    And I save the event
    Then I should see event forms popup

  Scenario: Should add the checked forms and remove unchecked forms.
    Given I am logged in as a super user
    And a basic morbidity event exists
    And a form for "AIDS" is present
    When I navigate to the morbidity event edit page
    And I select "AIDS" from "Diseases"
    And I save and continue
    And I check "form_id"
    And I click "save_forms_button"
    And I wait for the ajax request to finish
    Then I should see "Successfully added"

  Scenario: Should not see event forms popup if no disease update on save and exit
    Given I am logged in as a super user
    And a basic morbidity event exists
    And a form for "AIDS" is present
    When I navigate to the morbidity event edit page
    And I select "Anthrax" from "Diseases"
    And I save the event and wait for the page to load
    Then I should not see event forms popup

  Scenario: Should not see event forms popup if no disease update on save and continue
    Given I am logged in as a super user
    And a basic morbidity event exists
    And a form for "AIDS" is present
    When I navigate to the morbidity event edit page
    And I select "Anthrax" from "Diseases"
    And I save and continue
    Then I should not see event forms popup