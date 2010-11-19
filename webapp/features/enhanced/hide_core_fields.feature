Feature: Hiding and displaying core fields

  To speed up core field configuration
  As an admin
  I want to be able to hide and display core fields without opening and editing each field

  Scenario: Hiding and showing a tab
   Given I am logged in as a super user
     And I go to the core fields admin page
    When I hide a core field
    Then its hide button should change to a display button
    When I re-display the core field
    Then its display button should change to a hide button

