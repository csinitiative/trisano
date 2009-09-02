Feature: Viewing organisms

  To be able to properly manage organisms
  An administrator needs to be able to view organism details

  Scenario: An administrator views an organism
    Given I am logged in as a super user
      And an organism named "Arbovirus"
    When I go to the "Arbovirus" organism page
    Then I should see "Arbovirus"
      And I should see "Show an Organism"
      And I should see a link to "< Back to Organisms"

  Scenario: An investigator views an organism
    Given I am logged in as an investigator
      And an organism named "Arbovirus"
    When I go to the "Arbovirus" organism page
    Then I should get a 403 response