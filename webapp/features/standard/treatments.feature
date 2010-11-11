Features: Adding and editing treatments

  Background:
    Given I am logged in as a super user

  Scenario: Viewing the list of treatments
    Given the following treatments exist
    | treatment_name |
    | Rubbings       |
    | Foot massage   |
    | Leaches        |
    | Garlic         |
    When I go to the admin dashboard page
      And I follow "Manage Treatments"
    Then I should see "Rubbings"
      And I should see "Foot massage"
      And I should see "Leaches"
      And I should see "Garlic"

  Scenario: Adding a treatment
    When I go to the treatment admin page
      And I press "Create New Treatment"
      And I fill in "Treatment name" with "Rubbings"
      And I press "Create"
    Then I should see "Rubbings"
      And I should see "Treatment created"
      And I should see "Back to Treatments"

  Scenario: Adding an invalid treatment
    When I go to the treatment admin page
      And I press "Create New Treatment"
      And I press "Create"
    Then I should see "prohibited this treatment from being saved"

    When I fill in "Treatment name" with "Rubbings"
      And I press "Create"
    Then I should see "Rubbings"
      And I should see "Back to Treatments"

  Scenario: Editing a treatment
    Given the following treatments exist
    | treatment_name |
    | Rubbings       |
    When I go to the treatment admin page
      And I follow "Edit"
      And I fill in "Treatment name" with "Pinches"
      And I press "Update"
    Then I should see "Pinches"
      And I should see "Treatment updated"
      And I should see "Back to Treatments"

  Scenario: Marking a treatment as inactive
    Given the following treatments exist
    | treatment_name |
    | Rubbings       |
    When I go to the treatment admin page
      And I follow "Edit"
      And I uncheck "treatment_active"
      And I press "Update"
    Then I should see "Treatment updated"
      And I should see "Inactive"

    When I follow "Edit"
      And I check "treatment_active"
      And I press "Update"
    Then I should see "Treatment updated"
      And I should see "Active"

  Scenario: Marking a treatment as a default
    Given the following treatments exist
    | treatment_name |
    | Rubbings       |
    When I go to the treatment admin page
     And I follow "Edit"
     And I check "Default"
     And I press "Update"
    Then I should see "Treatment updated"
     And I should see "Default"

    When I follow "Edit"
     And I uncheck "Default"
     And I press "Update"
    Then I should see "Treatment updated" 
     And I should not see "Default"

