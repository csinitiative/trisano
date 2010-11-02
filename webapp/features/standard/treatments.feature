Features: Adding and editing treatments

  Scenario: Viewing the list of treatments
    Given I am logged in as a super user
    And the following treatments exist
    | treatment_name |
    | Rubbings       |
    | Foot massage   |
    | Leaches        |
    | Garlic         |
    When I go to the admin dashboard page
    And I follow "Manage Treatments"
    Then I should see "Rubbings"
    Then I should see "Foot massage"
    Then I should see "Leaches"
    Then I should see "Garlic"
    

