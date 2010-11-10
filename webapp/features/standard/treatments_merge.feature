Features: Merging treatments

  Background:
    Given I am logged in as a super user

  Scenario: Merging treatments
    Given the following treatments exist
    | treatment_name |
    | Foot area rubbings       |
    | Foot rubbings  |
    When I go to the treatment admin page
    And I fill in "Treatment" with "Rubbings"
    And I press "Search"
    And I click merge for "Foot area rubbings"
    Then I should see "Foot area rubbings" in the treatment merge section
    And I should see "Foot rubbings" in the treatment search results section




