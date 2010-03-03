Feature: Searching for people

  To simplify merging people
  An administrator need to be able to search for people

  Scenario: Searching by last name
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Unassigned for last name Jones
      And a simple morbidity event in jurisdiction Unassigned for last name Marx
     When I go to the people search page
      And I fill in "Last name" with "Marks"
      And I press "Search"
     Then I should see "Marx"
