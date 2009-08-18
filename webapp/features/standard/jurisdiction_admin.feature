Features: Managing jurisdictions

  To allow for system configuration
  Jurisdictions can be created, edited, and viewed

  Scenario: Accessing jurisdiction management from the admin dashboard
    Given I am logged in as a super user
    When I am on the admin dashboard page
    Then I should see "Manage Jurisdictions"

    When I follow "Manage Jurisdictions"
    Then I should see "Jurisdiction Management"
    
  Scenario: Successful jurisdiction creation
    Given I am logged in as a super user
    When I am on the jurisdictions page
    And I press "Create new jurisdiction"
    And I fill in "Name" with "Four Leaf Jurisdiction"
    And I fill in "Short name" with "The Leaf"
    And I press "Create"
    Then I should see "Jurisdiction was successfully created."
    And I should be on the show jurisdiction page

  Scenario: Successful jurisdiction creation after a validation failure
    Given I am logged in as a super user
    When I am on the jurisdictions page
    And I press "Create new jurisdiction"
    And I fill in "Name" with "Four Leaf Jurisdiction"
    And I press "Create"
    Then I should see "error prohibited"
    And I should not see "Jurisdiction was successfully created."
    
    When I fill in "Short name" with "The Leaf"
    And I press "Create"
    Then I should see "Jurisdiction was successfully created."
    And I should be on the show jurisdiction page

  Scenario: Successful jurisdiction update
    Given I am logged in as a super user
    And the jurisdiction "Four Leaf Jurisdiction" with the short name "The Leaf"
    When I am on the jurisdictions page
    And I follow "Edit"
    And I fill in "Name" with "Five Leaf Jurisdiction"
    And I fill in "Short name" with "The Fiver"
    And I press "Update"
    Then I should see "Jurisdiction was successfully updated."
    And I should be on the show jurisdiction page
    And I should see "Five Leaf Jurisdiction"
    And I should see "The Fiver"
    And I should not see "Four Leaf Jurisdiction"
    And I should not see "The Leaf"

Scenario: Successful jurisdiction update after a validation failure
    Given I am logged in as a super user
    And the jurisdiction "Four Leaf Jurisdiction" with the short name "The Leaf"
    When I am on the jurisdictions page
    And I follow "Edit"
    And I fill in "Name" with "Five Leaf Jurisdiction"
    And I fill in "Short name" with ""
    And I press "Update"
    Then I should see "error prohibited"
    And I should not see "Jurisdiction was successfully updated."

    When I fill in "Short name" with "The Fiver"
    And I press "Update"
    Then I should see "Jurisdiction was successfully updated."
    And I should be on the show jurisdiction page
    And I should see "Five Leaf Jurisdiction"
    And I should see "The Fiver"
    And I should not see "Four Leaf Jurisdiction"
    And I should not see "The Leaf"

Scenario: Viewing an existing jurisdiction
    Given I am logged in as a super user
    And the jurisdiction "Four Leaf Jurisdiction" with the short name "The Leaf"
    When I am on the jurisdictions page
    And I follow "Show"
    Then I should be on the show jurisdiction page
    
    