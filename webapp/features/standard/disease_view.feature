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
