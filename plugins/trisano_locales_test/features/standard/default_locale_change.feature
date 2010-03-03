Feature: Changing site default locale

  In order to support hosting sites that may have different default
  locales, without doing a reinstall
  Administrators need to be able to change the default locale

  Scenario: Viewing the current default locale
    Given I am logged in as a super user
     When I go to the admin dashboard
      And I follow "Manage Locale"
     Then I should be on the locale show page
      And I should see "Default Locale"
      And I should see default locale headers
      And I should see "English" as the default locale
      And I should see "System modified"

  Scenario: Editing current default locale
    Given I am logged in as a super user
     When I go to the locale show page
      And I follow "Edit"
     Then I should be on the locale edit page
      And I should see "Change Default Locale"
      And I should see default locale headers
     When I select "Test" from "short_name"
      And I submit the default locale edit form
     Then I should be on the locale show page
      And I should see "Test" as the default locale
      And I should see "default_user"
      And I should see "Default locale was successfully updated"
     When I follow "Edit"
     Then "Test" should be selected from "short_name"

  Scenario: Unauthorized access
    Given I am logged in as an investigator
     When I go to the admin dashboard
     Then I should not see "Manage Locale"
     When I go to the locale edit page
     Then I should get a 403 response
