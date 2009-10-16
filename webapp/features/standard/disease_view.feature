Feature: Viewing diseases

  Since diseases and their relationships are central to how much of
  TriSano works, its important that administrators be able to view
  diseases in detail

  Scenario: Viewing diseases for Organism relationships
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | The Trots    |
      And the following organisms are associated with the disease "The Trots":
        | Organism name       |
        | Burrito             |
        | Lactose Intolerance |
    When I go to view the disease "The Trots"
    Then I should see "Burrito"
      And I should see "Lactose Intolerance"

  Scenario: Viewing diseases to loinc code relationships
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | The Trots    |
      And the following loinc codes are associated with the disease "The Trots":
        | Loinc code | Scale |
        | 15234-1    | Ord   |
        | 636-9      | Qn    |
    When I go to view the disease "The Trots"
    Then I should see "636-9"
      And I should see "15234-1"

  Scenario: Viewing diseases to common test type links
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | The Trots    |
      And I have a common test type named Culture X
      And common test type "Culture X" is linked to the following diseases:
        | Disease name |
        | The Trots    |
    When I go to view the disease "The Trots"
    Then I should see "Common Test Types"
      And I should see "Culture X"

