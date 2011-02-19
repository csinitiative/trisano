Feature: Searching for people

  To simplify merging people
  An administrator need to be able to search for people

  Background:
    Given I am logged in as a super user
    And a patient named "Patientia Roberts"
    And a contact named "Contactia Roberts"
    And a clinician named "Cliniciania Roberts"
    And a reporter named "Reporteria Roberts"

  Scenario: Searching by last name only with fulltext
    When I go to the people search page
    And I fill in "Last name" with "Roberts"
    And I press "Search"
    Then I should see "Patientia"
    And I should see "Contactia"
    And I should see "Cliniciania"
    And I should see "Reporteria"

  Scenario: Searching by last name and interested party person type with fulltext
    When I go to the people search page
    And I fill in "Last name" with "Roberts"
    And I select "Interested party (patient, contact)" from "Person type"
    And I press "Search"
    Then I should see "Patientia"
    And I should see "Contactia"
    And I should not see "Cliniciania"
    And I should not see "Reporteria"

  Scenario: Searching by last name and clinician person type with fulltext
    When I go to the people search page
    And I fill in "Last name" with "Roberts"
    And I select "Clinician" from "Person type"
    And I press "Search"
    Then I should not see "Patientia"
    And I should not see "Contactia"
    And I should see "Cliniciania"
    And I should not see "Reporteria"

  Scenario: Searching by last name and reporter person type with fulltext
    When I go to the people search page
    And I fill in "Last name" with "Roberts"
    And I select "Reporter" from "Person type"
    And I press "Search"
    Then I should not see "Patientia"
    And I should not see "Contactia"
    And I should not see "Cliniciania"
    And I should see "Reporteria"

  Scenario: Searching by last name with starts-with
    When I go to the people search page
    And I fill in "Last name" with "R"
    And I check "Use starts with search"
    And I press "Search"
    Then I should see "Patientia"
    Then I should see "Contactia"
    Then I should see "Cliniciania"
    Then I should see "Reporteria"

  Scenario: Searching by last name and interested party person type with starts-with
    When I go to the people search page
    And I fill in "Last name" with "R"
    And I select "Interested party (patient, contact)" from "Person type"
    And I check "Use starts with search"
    And I press "Search"
    Then I should see "Patientia"
    And I should see "Contactia"
    And I should not see "Cliniciania"
    And I should not see "Reporteria"

  Scenario: Searching by last name and clinician person type with starts-with
    When I go to the people search page
    And I fill in "Last name" with "R"
    And I select "Clinician" from "Person type"
    And I check "Use starts with search"
    And I press "Search"
    Then I should not see "Patientia"
    And I should not see "Contactia"
    And I should see "Cliniciania"
    And I should not see "Reporteria"

  Scenario: Searching by last name and reporter person type with starts-with
    When I go to the people search page
    And I fill in "Last name" with "R"
    And I select "Reporter" from "Person type"
    And I check "Use starts with search"
    And I press "Search"
    Then I should not see "Patientia"
    And I should not see "Contactia"
    And I should not see "Cliniciania"
    And I should see "Reporteria"

  Scenario: Sorting with a search applied
    Given I am logged in as a super user
      And a simple morbidity event for full name John Doe
      And a simple morbidity event for full name Jane Doe
      And a simple morbidity event for last name Marx
     When I go to the people search page
      And I fill in "Last name" with "Doe"
      And I press "Search"
      And I follow "Person Name"
     Then I should see the following in order:
       | Jane |
       | John |
      And I follow "Person Name"
     Then I should see the following in order:
       | John |
       | Jane |
