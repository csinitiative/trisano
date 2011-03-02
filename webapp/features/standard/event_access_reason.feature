Feature: Logging access and reasons for accessing out-of-jurisdiction events

  Scenario: Users should be prompted to enter a reason when accessing an out-of-jurisdiction morbidity event
    Given a morbidity event exists in Out of state with the disease African Tick Bite Fever
    And I am logged in as an investigator
    When I am on the show CMR page
    Then I should see "Enter a reason for accessing an out-of-jurisdiction event."
    When I fill in "Reason" with "I just need to take a quick peek."
    And I press "Submit"
    Then I should be on the show CMR page
    And the system should have a record of access for the user and event with an access count of 1
    And I should see "You have accessed an out-of-jurisdiction event."
    And I should have a note that says "Extra-jurisdictional, view-only access"

  Scenario: Users should not be prompted on their second time accessing an out-of-jurisdiction morbidity event
    Given a morbidity event exists in Out of state with the disease African Tick Bite Fever
    And I am logged in as an investigator
    When I am on the show CMR page
    Then I should see "Enter a reason for accessing an out-of-jurisdiction event."
    When I fill in "Reason" with "I just need to take a quick peek."
    And I press "Submit"
    Then I should be on the show CMR page
    And the system should have a record of access for the user and event with an access count of 1

    When I am on the show CMR page
    Then the system should have a record of access for the user and event with an access count of 2

  Scenario: Users should receive an error if no reason is entered when they first access the morbidity event
    Given a morbidity event exists in Out of state with the disease African Tick Bite Fever
    And I am logged in as an investigator
    When I am on the show CMR page
    Then I should see "Enter a reason for accessing an out-of-jurisdiction event."
    And I press "Submit"
    Then I should see "Reason can't be blank."

    When I fill in "Reason" with "I just need to take a quick peek."
    And I press "Submit"
    Then the system should have a record of access for the user and event with an access count of 1

  Scenario: Users should be prompted to enter a reason when accessing an out-of-jurisdiction contact event
    Given a contact event exists in Out of state with the disease African Tick Bite Fever
    And I am logged in as an investigator
    When I am on the contact show page
    Then I should see "Enter a reason for accessing an out-of-jurisdiction event."
    When I fill in "Reason" with "I just need to take a quick peek."
    And I press "Submit"
    Then I should be on the contact show page
    And the system should have a record of access for the user and event with an access count of 1
    And I should see "You have accessed an out-of-jurisdiction event."
    And I should have a note that says "Extra-jurisdictional, view-only access"
