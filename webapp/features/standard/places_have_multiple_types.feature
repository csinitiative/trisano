Feature: Allow all 'places' to have multiple types

  So as to promote consistency between reporting agencies and all other places
  As an investigator
  I want to be able to add more than one type to each place

  Scenario: Adding multiple types to places
    Given I am logged in as a super user

    When I go to the new CMR page
    And I enter a last name of Smith
    And I fill in "Date first reported to public health" with "September 14, 2010"
    And I select School and Laboratory types for the diagnostic facility
    And I select Pool and Daycare types for the place exposure
    And I select Public and Other types for the reporting agency

    Then I should be able to save the form and see my selections