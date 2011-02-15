Feature: Managing a list of treatments

  To avoid duplication of treatment strings
  As an admin
  I want to be able to maintain a list of treatments that users can pick from

  Scenario: Treatments are sorted alphabetically by default
    Given the following treatments exist
      | treatment_name |
      | Rubbings       |
      | Foot massage   |
      | Leaches        |
      | Garlic         |
    When I navigate to the admin dashboard page
    And I click the "Manage Treatments" link
    Then I should see the following in order:
      | Foot massage   |
      | Garlic         |
      | Leaches        |
      | Rubbings       |

  Scenario: Clicking the heading twice should reverse the sort
    Given the following treatments exist
      | treatment_name |
      | Rubbings       |
      | Foot massage   |
      | Leaches        |
      | Garlic         |
    When I navigate to the admin dashboard page
    And I click the "Manage Treatments" link
    And I click the "Treatments" table header 2 times
    Then I should see the following in order:
      | Rubbings       |
      | Leaches        |
      | Garlic         |
      | Foot massage   |
