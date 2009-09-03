Feature: Listing organisms

  To simplify navigation through the list of organisms
  An admin can view a list of all the organisms in the system.

  Scenario: An admin lists all organisms
    Given I am logged in as a super user
      And the following organisms:
        | Organism Name   |
        | Arbovirus       |
        | Influenza A     |
        | Influenza B     |
        | E. Coli         |
        | Legionella      |
    When I go to the organisms index page
    Then I should see the following organisms:
        | Organism Name   | Actions      |
        | Arbovirus       | Show,Edit    |
        | E. Coli         | Show,Edit    |
        | Influenza A     | Show,Edit    |
        | Influenza B     | Show,Edit    |
        | Legionella      | Show,Edit    |

  Scenario: An investigator tries to list organisms
    Given I am logged in as an investigator
    When I go to the organisms index page
    Then I should get a 403 response

  Scenario: An administrator navigates to new organism screen
    Given I am logged in as a super user
    When I go to the organisms index page
      And I press "Create New Organism"
    Then I should be on the new organism page

  Scenario: An administrator navigates to an organism show page
    Given I am logged in as a super user
      And an organism named "Arbovirus"
    When I go to the organisms index page
      And I follow "Show"
    Then I should be on the "Arbovirus" organism page

  Scenario: An administrator navigates to an organism's edit page
    Given I am logged in as a super user
      And an organism named "Arbovirus"
    When I go to the organisms index page
      And I follow "Edit"
    Then I should be on the "Arbovirus" edit organism page