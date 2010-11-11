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
    And I should not see "Foot area rubbings" in the treatment search results section

    When I select the merge check box for the treatment "Foot rubbings"
    And I click the "Merge" button
    Then I should see "Merge successful."
    And I should not see "Foot rubbings"

  Scenario: Attempting to merge treatments without choosing a treatment to merge
    Given the following treatments exist
    | treatment_name |
    | Foot area rubbings       |
    | Foot rubbings  |
    When I go to the treatment admin page
    And I click merge for "Foot area rubbings"
    And I click the "Merge" button
    Then I should see "Unable to merge treatments: No treatments were provided for merging."

  Scenario: Search results should stick around through merging activities
    Given the following treatments exist
    | treatment_name |
    | Foot area rubbings       |
    | Foot rubbings  |
    | Hand rubbings  |
    | Kick in the pants  |
    When I go to the treatment admin page
    And I fill in "Treatment" with "Rubbings"
    And I press "Search"
    Then I should see "Foot area rubbings" in the treatment search results section
    And I should see "Foot rubbings" in the treatment search results section
    And I should see "Hand rubbings" in the treatment search results section
    And I should not see "Kick in the pants" in the treatment search results section

    When I click merge for "Foot area rubbings"
    Then I should see "Foot rubbings" in the treatment search results section
    And I should see "Hand rubbings" in the treatment search results section
    And I should not see "Kick in the pants" in the treatment search results section

    When I select the merge check box for the treatment "Foot rubbings"
    And I click the "Merge" button
    Then I should see "Hand rubbings" in the treatment search results section
    And I should not see "Kick in the pants" in the treatment search results section

    When I follow "Cancel"
    Then I should see "Foot area rubbings" in the treatment search results section
    And I should see "Hand rubbings" in the treatment search results section
    And I should not see "Kick in the pants" in the treatment search results section

    When I follow "< Clear Search Criteria"
    Then I should see "Foot area rubbings" in the treatment search results section
    And I should see "Hand rubbings" in the treatment search results section
    And I should see "Kick in the pants" in the treatment search results section
    

