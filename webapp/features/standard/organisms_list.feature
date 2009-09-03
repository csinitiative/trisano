Feature: Listing organisms

  To simplify navigation through the list of organisms
  An admin can view a list of all the organisms in the system.

  Scenario: An admin lists all organisms
    Given I am logged in as a super user
      And the following organisms:
        | organism_name   |
        | Arbobirus       |
        | Influenza A     |
        | Influenza B     |
        | E. Coli         |
        | Legionella      |
    When I go to the organisms index page
    Then I should see the following organisms:
        | Organism Name   |
        | Arbobirus       |
        | E. Coli         |
        | Influenza A     |
        | Influenza B     |
        | Legionella      |
