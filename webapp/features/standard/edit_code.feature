Feature: Editing system codes

  I want to be able to edit a system code
  As an admin
 
  Scenario: Viewing a code name/type
    Given a code name "gender" exists
    And a code in name "gender" with the code "F" exists
    And I am logged in as a super user

    When I navigate to the code management tool
    And I follow "Gender"

    Then I should see "Gender Codes"
    And I should see "Female"

  Scenario: Viewing a specific code
    Given a code name "gender" exists
    And a code in name "gender" with the code "F" exists
    And I am logged in as a super user

    When I navigate to the code list for code name "gender"
    And I follow "Female"

    Then I should see "Code Information"
    And I should see "Gender - F - Code Detail"

    When I follow "Edit"

    Then I should see "Edit Code"
    And I should see "Update"

  Scenario: Invalid code name/type or code should result in an error
    Given a code name "bogus" does not exist
    And a code in name "gender" with the code "bogus" does not exist
    And I am logged in as a super user

    When I navigate to the code list for code name "bogus"
    Then I should see "Couldn't find"

    When I navigate to the code edit for code name "gender" and the code "bogus"
    Then I should see "Couldn't find"

    When I navigate to the code edit for code name "bogus" and the code "more_bogus"
    Then I should see "Couldn't find"

    When I navigate to the code edit for code name "bogus" and the code "NEW"
    Then I should see "Couldn't find"
 
  Scenario: Excercise code creation, editing and deletion
#  Scenario: Creating a new code
    Given a code name "gender" exists
    And a code in name "gender" with the code "NEW" does not exist
    And I am logged in as a super user

    When I navigate to the code list for code name "gender"
    And I press "New Gender Code"
    And I fill in "external_code_the_code" with "NEW"
    And I fill in "external_code_code_description" with "New Code"
    And I fill in "external_code_sort_order" with "5"
    And I press "Create"

    Then a code in name "gender" with the code "NEW" exists
    And I should see "New Code"

#  Scenario: Duplicate code should result in error
#    Given a code name "gender" exists
#    And a code in name "gender" with the code "NEW" exists
#    And I am logged in as a super user

    When I navigate to the code list for code name "gender"
    And I press "New Gender Code"
    And I fill in "external_code_the_code" with "NEW"
    And I fill in "external_code_code_description" with "Duplicate New Code"
    And I fill in "external_code_sort_order" with "0"
    And I press "Create"

    Then I should see "Error"

#  Scenario: Editing the new code
#    Given a code in name "gender" with the code "NEW" exists

    When I navigate to the code edit for code name "gender" and the code "NEW"
    And I fill in "external_code_code_description" with "New Code Updated"
    And I press "Update"

    Then I should see "New Code Updated"
    And I should see "Active"

#  Scenario: Soft delete of the new code
#    Given a code in name "gender" with the code "NEW" exists

    When I navigate to the code edit for code name "gender" and the code "NEW"
    And I follow "Delete"

    Then I should see "Code was successfully deleted"
    And a code in name "gender" with the code "NEW" exists
    And a code in name "gender" with the code "NEW" is soft deleted

    When I navigate to the code edit for code name "gender" and the code "NEW"
    Then I should see "Undelete"
    And I should not see "Active"

#  Scenario: Undelete of the new code
#    Given a code in name "gender" with the code "NEW" exists

    When I navigate to the code edit for code name "gender" and the code "NEW"
    And I follow "Undelete"

    Then I should see "Code was successfully restored"
    And a code in name "gender" with the code "NEW" exists
    And a code in name "gender" with the code "NEW" is not soft deleted

    When I navigate to the code edit for code name "gender" and the code "NEW"
    Then I should see "Delete"
    And I should see "Active"
