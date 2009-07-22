Feature: Searching for duplicate places

  To enable management of places
  As an admin
  I want to be able to search for places by name

  Scenario: Searching for a place by name
    Given a lab named Manzanita Health Facility exists
    Given a diagnosing facility named Manzanita Health Facility exists
    And I am logged in as a super user

    When I navigate to the place management tool
    And I search for Manzanita

    Then I should receive 2 matching records

  Scenario: Searching for a place by name and participation type
    Given a lab named Manzanita Health Facility exists
    Given a diagnosing facility named Manzanita Health Facility exists
    And I am logged in as a super user

    When I navigate to the place management tool
    And I search for Manzanita with a participation type of Lab

    Then I should receive 1 matching record for a lab
    