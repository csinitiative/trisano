Feature: Active forms must have unique short names 

  To provide better scoping for the export of form builder data
  A form builder must provide a unique short name when creating a form

  Scenario: Creating a new form
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | African Tick Bite Fever |
    When I navigate to the new form view
    And I enter a form name of Lipsom
    And I enter a form short name of lipsom_form
    And I select a form event type of Morbidity Event
    And I check the disease African Tick Bite Fever

    Then I should be able to create the new form and see the form name Lipsom

  Scenario: Creating a new form with a blank short name
    Given I am logged in as a super user
      And the following active diseases:
        | Disease name |
        | African Tick Bite Fever |

    When I navigate to the new form view
    And I enter a form name of Lipsom
    And I select a form event type of Morbidity Event
    And I check the disease African Tick Bite Fever
    And I press "Create"

    Then I should see error "Short name can't be blank"

  Scenario: Creating a form with a duplicate short name
    Given I am logged in as a super user
    And I already have a form with the short name "duplicate_short_name"

    When I navigate to the new form view
    And I enter a form name of Lipsom
    And I re-enter the duplicate short name
    And I select a form event type of Morbidity Event
    And I check the disease African Tick Bite Fever
    And I press "Create"

    Then I should see error "Short name is already being used by another active form."

  Scenario: Creating a form w/ the same short name as a deactivated form
    Given I am logged in as a super user
    And I already have a deactivated form with the short name "duplicate_short_name"

    When I navigate to the new form view
    And I enter a form name of Lipsom
    And I re-enter the duplicate short name
    And I select a form event type of Morbidity Event
    And I check the disease African Tick Bite Fever

    Then I should be able to create the new form and see the form name Lipsom

  Scenario: Editing a form's short name, before it's been published
    Given I am logged in as a super user
    And I already have a form with the short name "edit_me"

    When I navigate to the form edit view

    Then I should be able to fill in the short name field

  Scenario: Editing a form's short name, after it's been published
    Given I am logged in as a super user
    And I already have a published form

    When I navigate to the form edit view
    
    Then I should not be able to fill in the short name field
