Feature: Automatically building metadata overlay

  To simplify the process by which form builder data gets into the datawarehouse
  The system needs to be able to automatically update the metadata overlay

  Scenario: Add a new formbuilder table to the overlay
    Given the core metadata overlay
    And a new formbuilder table

    When I run the update script

    Then I should have a new Physical Table
    And I should have a new, secured Business Table
    And I should have a new Relationship
    And I should have a new Category
