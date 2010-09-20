Feature: Configuring which core fields render by disease

  Since not every disease needs every core field answered, and it's inefficient to display fields that aren't answered
  As an admin
  I want to be able to configure which fields are displayed for each disease

  Scenario: Navigating to the disease specific core field configuration
    Given I am logged in as a super user
     And the following active diseases:
       | Disease name |
       | The Trots    |
     When I go to view the disease "The Trots"
      And I follow "Core fields"
     Then I should be on the "The Trots" core fields page

