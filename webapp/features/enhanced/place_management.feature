Feature: Managing places through the admin console

  To avoid duplication in auxillary places
  As an admin
  I want to be able to mange places.

  Background:
    Given the following place types:
        | type       |
        | Planet     |
      And the following places:
        | name    | type      |
        | Mars    | Planet    |
        | Jupiter | Planet    |
        | Neptune | Planet    |
      And places have these addresses:
        | place   | number | street       |
        | Mars    | 12     | Happy Street |
        | Jupiter | 214    | Main St.     |
        | Neptune | 3      | MLK Blvd.    |


  Scenario: Sorting places by name
    When I open the place management tool
     And I click the "Search" button and wait for the page to load
    Then I should see the following in order:
      | Jupiter |
      | Mars    |
      | Neptune |
    When I click the "Place name" table header 2 times
    Then I should see the following in order:
      | Neptune |
      | Mars    |
      | Jupiter |


  Scenario: Sorting places by address
    When I open the place management tool
     And I click the "Search" button and wait for the page to load
     And I click the "Address" table header
    Then I should see the following in order:
      | Mars |
      | Jupiter |
      | Neptune |
    When I click the "Address" table header
    Then I should see the following in order:
      | Neptune |
      | Jupiter |
      | Mars |


  Scenario: Sorting places by place type
    When I open the place management tool
     And I click the "Search" button and wait for the page to load
     And I click the "Place type" table header
    Then I should see the following in order:
      | Hospital |
      | Jurisdiction |
      | Planet |
    When I click the "Place type" table header
    Then I should see the following in order:
      | Planet |
      | Jurisdiction |
      | Hospital |
