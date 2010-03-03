Feature: Changing the application locale

  In order to support data entry in countries with multiple common languages
  Users need to be able to select their own locale

  Scenario: Creating a new common test type in a non-default locale
    Given I am logged in as a super user
      And I have selected the "Test" locale
     When I follow "xADMIN"
      And I follow "xManage Common Test Types"
      And I press "xCreate New Common Test Type"
     Then I should see "Create a Common Test Type"
      And I should see a link to "x< Back to Common Test Types"
     When I fill in "common_test_type_common_name" with "Culture X"
      And I press "xCreate"
     Then I should see "xShow a Common Test Type"
      And I should see "Culture X"

  Scenario: Event searching retains locale information
    Given I am logged in as a super user
      And I have selected the "Test" locale
     When I follow "xSEARCH"
      And I press "xSubmit Query"
     Then I should still see locale "Test"

