Feature: Active forms must have unique short names 

  To provide better scoping for the export of form builder data
  A form builder must provide a unique short name when creating a form

  Scenario: Creating a new form
    Given I am logged in as a super user
    
    When I navigate to the new form view
    And I enter a form name of Lipsom
    And I enter a form short name of lipsom_form
    And I select a form event type of Morbidity event
    And I check the disease African Tick Bite Fever

    Then I should be able to create the new form and see the form name Lipsom

  Scenario: Creating a new form with a blank short name
    Given I am logged in as a super user

    When I navigate to the new form view
    And I enter a form name of Lipsom
    And I select a form event type of Morbidity event
    And I check the disease African Tick Bite Fever
    And I press "Create"

    Then I should see error "Short name can't be blank"

  Scenario: Creating a form with a duplicate short name
    Given I am logged in as a super user
    And I have already created a form with the short name "duplicate_short_name"

    When I navigate to the new form view
    And I enter a form name of Lipsom
    And I re-enter the duplicate short name
    And I select a form event type of Morbidity event
    And I check the disease African Tick Bite Fever
    And I press "Create"

    Then I should see error "Short name is already being used by another active form."