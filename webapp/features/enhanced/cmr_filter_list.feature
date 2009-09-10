Feature: Filtering the CMR list view

  To work more efficiently, users need to be able to filter the CMR
  list to focus on the cases they care about most.

  @clean
  Scenario: Filtering the CMR list by one disease
    Given I am logged in as a super user
      And morbidity events with the following diseases:
        | disease_name  |
        | Anthrax       |
        | AIDS          |
        | AIDS          |
    When I am on the events index page
    Then events list should show 3 events
    When I select "AIDS" from "Diseases"
      And I click the "Change View" button
      And I wait for the page to load
    Then events list should show 2 events

  @clean
  Scenario: Filtering the CMR list by multiple diseases
    Given I am logged in as a super user
      And morbidity events with the following diseases:
        | disease_name  |
        | Anthrax       |
        | AIDS          |
        | Brucellosis   |
    When I am on the events index page
    Then events list should show 3 events
    When the following values are selected from "Diseases":
      | Anthrax |
      | AIDS    |
      And I click the "Change View" button
      And I wait for the page to load
    Then events list should show 2 events