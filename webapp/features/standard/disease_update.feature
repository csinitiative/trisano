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

  Scenario: Set disease export status
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | The Trots    |
    When I go to edit the disease named "The Trots"
      And I check "Confirmed"
      And I check "Probable"
      And I press "Update"
    Then I should see "Disease was successfully updated"
      And I should see "Confirmed, Probable"

  Scenario: Unset disease export status
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | The Trots    |
      And the disease "The Trots" is exported when "Confirmed"
    When I go to edit the disease named "The Trots"
      And I uncheck "Confirmed"
      And I press "Update"
    Then I should see "Disease was successfully updated"
      And I should not see "Confirmed"

  Scenario: Configure AVR groups
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | The Trots    |
      And the following AVR groups:
        | name |
        | enterics |
        | bad lurgies |
        | not so bad lurgies |
    When I go to edit the disease named "The Trots"
      And I check "enterics"
      And I check "bad_lurgies"
      And I press "Update"
    Then I should see "Disease was successfully updated"
      And I should see "enterics"
      And I should see "bad lurgies"
      And I should not see "not so bad lurgies"

  Scenario: Configure no AVR groups
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | The Trots    |
      And the following AVR groups:
        | name |
        | enterics |
        | bad lurgies |
        | not so bad lurgies |
    When I go to edit the disease named "The Trots"
      And I press "Update"
    Then I should see "Disease was successfully updated"
      And I should see "No AVR groups configured"