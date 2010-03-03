Feature: Searching places

  To simplify managing places
  As an admin
  I want to be able to search places

  Scenario: Searching for a place by name
    Given a lab named Super Evil Villiany Lab exists
      And the place entity has a canonical address of:
        | street_number | street_name  | city    | state | postal_code |
        |           435 | Wilson-Mills | Milford | OH    |       44444 |
      And a lab named Super Evil Annex exists
      And the place entity has a canonical address of:
        | street_number | street_name | city      | state | postal_code |
        |           101 | Tabitha     | Ohio City | OH    |       44123 |
      And I am logged in as a super user
     When I go to the places search page
      And I fill in "Place name" with "Super Evil"
      And I press "Search"
     Then I should see "Super Evil Villiany Lab"
      And I should see "Wilson-Mills"
      And I should see "Ohio"
      And I should see "Tabitha"
      And I should see "Super Evil Annex"
