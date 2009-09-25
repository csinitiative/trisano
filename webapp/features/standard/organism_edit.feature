Feature: Editing an organism

  To properly manage the labs and ELRs in the system
  An administrator needs to be able to modify existing organisms.

  Scenario: An administrator updates an organism's name
    Given I am logged in as a super user
      And an organism named "Arbovirus"
    When I go to the "Arbovirus" edit organism page
      And I fill in "Organism name" with "Inkoo virus"
      And I press "Update"
    Then I should be on the "Inkoo virus" organism page
      And I should see "Organism was successfully updated"
      And I should see "Inkoo"
      And I should not see "Arbovirus"

  Scenario: An administrator makes an invalid update to an organism
    Given I am logged in as a super user
      And the following organisms:
        | Organism Name   |
        | Arbovirus       |
        | Influenza A     |
    When I go to the "Arbovirus" edit organism page
      And I fill in "Organism name" with "Influenza A"
      And I press "Update"
    Then I should get a 400 response
      And I should see "Organism name has already been taken"

  Scenario: An investigator cannot edit an organism
    Given I am logged in as an investigator
      And an organism named "Arbovirus"
    When I go to the "Arbovirus" edit organism page
    Then I should get a 403 response

  Scenario: Associate a disease with an organism
    Given I am logged in as a super user
      And an organism named "Arbovirus"
    When I go to the "Arbovirus" edit organism page
      And I select "Dengue" from "Disease"
      And I press "Update"
    Then I should see "Organism was successfully updated"
      And I should be on the "Arbovirus" organism page
      And I should see "Dengue"

