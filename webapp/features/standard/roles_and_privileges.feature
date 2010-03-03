Feature: Managing roles and privileges

  In order to manage user access rights admins need to be able to view
  and edit permissions associated with roles

  Scenario: Viewing privileges associated with roles
    Given I am logged in as a super user
    When I go to the edit "Administrator" role page
    Then I should see "Create staged messages"
     And I should see "Administer"
     And I should see "Add forms to events"
