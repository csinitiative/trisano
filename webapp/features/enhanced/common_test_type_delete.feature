Feature: Deleting common test types

  To simplify administration of common test types
  Administrators need to be able to remove common test types if they aren't being used.

  @clean_common_test_types
  Scenario: Deleting a common test type from show mode
    Given I am logged in as a super user
    And I have a common test type named Culture
    When I navigate to show common test type
    Then I should see a link to "Delete"

    When I click the "Delete" link
    Then I should see "Common test type was successfully deleted"
    And I should not see "Culture"

  @clean_common_test_types @clean_lab_results
  Scenario: Deleting a common test type referenced by a lab result
    Given I am logged in as a super user
    And I have a common test type named Culture
    And I have a lab result
    And the lab result references the common test type
	And no other common test types exist

    When I navigate to show common test type
    Then I should not see a link to "Delete"

