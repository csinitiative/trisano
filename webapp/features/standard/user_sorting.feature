Feature: An admin can select how to sort the list of users

  To simplify user management
  An admin should be able to sort users by various user attributes

  Scenario: Sorting the users by UID
    Given I am logged in as a super user
    And the follow users are in the system:
      | uid  | active | 
    And I am on user index page
