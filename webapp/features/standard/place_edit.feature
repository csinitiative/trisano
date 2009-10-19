Feature: Editing places

  To enable cleanup of place data
  As an admin
  I want to be able to edit a place

  Scenario: Editing a lab
    Given a lab named Manzanita Health Facility exists
    And I am logged in as a super user

    When I am on the place edit page
    And I change the place name to Manzanita Health Dot Com
    And I enter a canonical address
    And I submit the place update form

    Then the place name change to Manzanita Health Dot Com should be reflected on the show page
    And the canonical address should be displayed on the show page

  Scenario: Editing a lab with invalid information
    Given a lab named Manzanita Health Facility exists
    And I am logged in as a super user

    When I am on the place edit page
    And I enter invalid place data
    And I submit the place update form

    Then the place edit form should be redisplayed with an error message

  Scenario: Navigating to the parent cmr in edit mode
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Bear River for last name Smoker
      And there is a place on the event named Red Dragon Pavilion
    When I go to the first CMR place's edit page
      And I follow "Smoker"
    Then I should be on edit the CMR
