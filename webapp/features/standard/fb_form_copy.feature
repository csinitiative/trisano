Feature: Forms can be copied

  So as to simplify the form building process
  As a form builder
  I want to be able to copy an existing form

  Scenario: Copy a form
    Given I am logged in as a super user
      And I already have a form with the name "Simple Form"
     When I go to the form builder page
      And I follow "Copy"
     Then I should see "Simple Form \(Copy\)"
      And I should be on the "Simple Form (Copy)" edit form page
