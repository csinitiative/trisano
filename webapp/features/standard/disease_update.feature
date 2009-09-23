Feature: Updating diseases

  To customize TriSano to work for their users, administrators need to
  be able to update existing diseases.

  Scenario: Make disease inactive
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | The Trots    |
    When I go to edit the disease named "The Trots"
      And I uncheck "Active?"
      And I press "Update"
    Then I should see "Disease was successfully updated"
      And I should see "Inactive"
