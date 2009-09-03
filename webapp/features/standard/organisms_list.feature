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

  Scenario: An investigator tries to list organisms
    Given I am logged in as an investigator
    When I go to the organisms index page
    Then I should get a 403 response

  Scenario: An administrator navigates to new organism screen
    Given I am logged in as a super user
    When I go to the organisms index page
      And I press "Create New Organism"
    Then I should be on the new organism page