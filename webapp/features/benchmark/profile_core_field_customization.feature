Feature: Event loading performance is sane

  So that I can work productivity
  As a user
  I want event saves and loads to be fast

  Background:
    Given I am logged in as a super user

  Scenario: Page load of edit assessment event with no forms
      Given a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
      And I begin monitoring performance
      And I am on the assessment event edit page
      And I end monitoring performance of "ae_edit_no_forms" 

  Scenario: Page load of edit assessment event with one unanswered form
      Given a assessment event form named Mumps Form 1 (mumps1) exists for the disease Mumps
      And that form has core field configs configured for all core fields
      And that form is published
      And a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
      And I begin monitoring performance
     When I am on the assessment event edit page
      And I end monitoring performance of "ae_edit_empty_forms"

   Scenario: Page load of save & continue, edit page on assessment event with answered form questions
      Given a assessment event form named Mumps Form 1 (mumps1) exists for the disease Mumps
      And that form has core field configs configured for all core fields
      And that form is published
      And a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
     When I am on the assessment event edit page
      And I answer all core field config questions
      And I begin monitoring performance
      And I save the event
      And I end monitoring performance of "ae_edit_fillin_forms_show_page"
      And I begin monitoring performance
      And I am on the assessment event edit page
      And I end monitoring performance of "ae_edit_completed_forms"

  Scenario: Page load of edit assessment with two unanswered forms
      Given a assessment event form named Mumps Form 1 (mumps1) exists for the disease Mumps
      Given a assessment event form named Mumps Form 2 (mumps2) exists for the disease Mumps
      And that form has core field configs configured for all core fields
      And that form is published
      And a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
      And I begin monitoring performance
     When I am on the assessment event edit page
      And I end monitoring performance of "ae_edit_empty_two_forms"
    
