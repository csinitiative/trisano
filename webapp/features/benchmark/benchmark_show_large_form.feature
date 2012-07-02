
Feature: Event loading performance is sane

  So that I can work productivitly
  As a user
  I want event show to be fast even when there are lots of fields

  Background:
    Given I am logged in as a real world user

  Scenario: Show event with large forms
    Given I start benchmarking
      And I test the show event page of a large form
     Then I should get a 200 response
      And I stop benchmarking of "show_event_with_large_form" 
