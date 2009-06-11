Feature: Staging Electronic Messages

  To process electonically submitted messages
  A user needs to be able to view messages and assign them to CMRs

  @pending
  Scenario: Accessing the staging area with the right privileges
    Given I am logged in as a user with create and update privs in the Unassigned jurisdiction
    When I follow "STAGING AREA"
    Then I should see the staging area page

  @pending
  Scenario: Accessing the staging area with the wrong privileges
    Given I am logged in as a user without create and update privs in the Unassigned jurisdiction
    Then I should not see the staging area link

    When I visit the staging area page directly
    Then I should get a 403 response
