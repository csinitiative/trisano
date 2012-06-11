Feature: Ajax-y searches from within AEs

  In order to improve data integrity
  As an investigator
  I need to be able to search for existing enitities while filling in cases

  Scenario: Searching for diagnostic facilities
    Given a diagnostic facility named "Hiccup Labs"
     When in a assessment event, I search for a diagnostic facility named "Hiccup"
     Then I should see "Hiccup Labs"

  Scenario: Searching for place exposures
    Given a place exposure named "McWendy's Playland"
     When in a assessment event, I search for a place exposure named "mcwend"
     Then I should see "McWendy's Playland"

  Scenario: Searching for a reporting agency
    Given a reporting agency named "Angie's Reporting"
     When in a assessment event, I search for a reporting agency named "Angie"
     Then I should see "Angie's Reporting"
