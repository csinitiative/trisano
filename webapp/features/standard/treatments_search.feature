Features: Searching for treatments

  Background:
    Given I am logged in as a super user

  Scenario: Searching for treatments
    Given the following treatments exist
    | treatment_name |
    | Rubbings       |
    | Foot rubbings  |
    | Foot massage   |
    When I go to the treatment admin page
      And I fill in "Treatment" with "Rubbings"
      And I press "Search"
    Then I should see "Rubbings"
      And I should see "Foot rubbings"
      And I should not see "Foot massage"

  Scenario: Clearing search criteria
    Given the following treatments exist
    | treatment_name |
    | Rubbings       |
    | Foot rubbings  |
    | Foot massage   |
    When I go to the treatment admin page
      And I fill in "Treatment" with "Rubbings"
      And I press "Search"
      And I follow "< Clear Search Criteria"
    Then I should see "Rubbings"
      And I should see "Foot rubbings"
      And I should see "Foot massage"

