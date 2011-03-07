Feature: Viewing access records

  Scenario: State managers should be able to see the link for access records on the dashboard
    Given I am logged in as a state manager
    When I am on the dashboard page
    Then I should see "Tools"
    And I should see "Event Access Records"

  Scenario: Non-state managers should not be able to see the link for access records on the dashboard
    Given I am logged in as an investigator
    When I am on the dashboard page
    Then I should not see "Tools"
    And I should not see "Event Access Records"
    When I am on the access records page
    Then I should see "You do not have permission to view event access records."

    Given I am logged in as a manager
    When I am on the dashboard page
    Then I should not see "Tools"
    And I should not see "Event Access Records"
    When I am on the access records page
    Then I should see "You do not have permission to view event access records."

    Given I am logged in as a lhd manager
    When I am on the dashboard page
    Then I should not see "Tools"
    And I should not see "Event Access Records"
    When I am on the access records page
    Then I should see "You do not have permission to view event access records."

    Given I am logged in as a data entry tech
    When I am on the dashboard page
    Then I should not see "Tools"
    And I should not see "Event Access Records"
    When I am on the access records page
    Then I should see "You do not have permission to view event access records."

  Scenario: State managers should be able to see access records
    Given a morbidity event exists in Out of state with the disease African Tick Bite Fever
    And I am logged in as an investigator
    When I am on the show CMR page
    And I fill in "Reason" with "I just need to take a quick peek."
    And I press "Submit"
    Then I should be on the show CMR page

    When I am logged in as a state manager
    And I am on the dashboard page
    And I follow "Event Access Records"
    Then I should see "investigator"
    And the record number of the event accessed should be visible
    And I should see "I just need to take a quick peek."

    When I am logged in as a super user
    And I am on the dashboard page
    And I follow "Event Access Records"
    When I access the event by clicking the record number
    Then I should be on the CMR show page

  Scenario: Access records should be paginated
    Given I have 31 access records in the system
    And I am on the access records page
    Then I should see "Next &raquo;"
    