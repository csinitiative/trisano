Feature: An administrator can associate treatments w/ diseases

  Background:
    Given I am logged in as a super user
      And disease "The Trots" exists

  Scenario: Managing treatment associations from the disease admin
    When I go to edit the disease named "The Trots"
     And I follow "Treatments"
    Then I should be on the disease specific treatments page for "The Trots"

  Scenario: Find and associate treatments using Search
    Given the following treatments:
      | treatment_name | active | default |
      | Beer           | true   | true    |
      | Shot           | true   | true    |
      | Leeches        | true   | true    |
     When I go to the disease specific treatments page for "The Trots"
      And I search treatments for "Beer"
     Then I should see "Beer"
      And I should not see "Shot"
      And I should not see "Leeches"
     When I choose the association check box for the treatment "Beer"
      And I press "Add"
     Then I should see "Disease treatments updated"
      And I should see "Beer" in the associated treatments section

  Scenario: Find and associate treatments using Search
    Given the following treatments:
      | treatment_name | active | default |
      | Beer           | true   | true    |
      | Shot           | true   | true    |
      | Leeches        | true   | true    |
      And the following treatments are assocaited with the disease "The Trots":
      | treatment_name |
      | Beer           |
     When I go to the disease specific treatments page for "The Trots"
     Then I should see "Beer" in the associated treatments section
     When I choose the association check box for the treatment "Beer"
      And I press "Remove"
     Then I should see "Disease treatments updated"
      And I should not see "Beer" in the associated treatments section
