Feature: Configuring core fields to render by default

  Since not every case of rendering core fields will have a disease associated with it
  As an admin
  I want to be able to configure which fields to display when no disease is selected

  Scenario: Make a core field disease specific (not default)
    Given I am logged in as a super user
     When I go to the "Patient first name" core field
      And I uncheck "Display when no disease selected"
      And I press "Update"
     Then I should see "Disease specific core"
