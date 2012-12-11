Feature: Event Routing Fail

  If routing an event fails
  users need to be able to take action to correct the event.

  Scenario: Assigning to a local health department
    Given I am logged in as a super user
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
     When I am on the CMR show page
     Then I should see "Unassigned"
     When I route it to Bear River
     Then I should see "Assigned to Local Health Dept."

  Scenario: Routing an event that has become invalid when user can update
    Given I am logged in as a super user
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And the event disease onset date is invalid
     When I am on the CMR show page
     Then I should see "Davis County Health Department"
     When I route it to Bear River
     Then I should see "Unable to route CMR"
      And I should see "Onset date must be on or before"
      And I should see "There were problems with the following fields"
      And I should get a 400 response
      And jurisdiction "Davis County Health Department" should be selected

  Scenario: Routing an event that has become invalid when user can't update
    Given I am logged in as a manager
      And I am not able to update events
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Bear River
      And the event disease onset date is invalid
     When I am on the CMR show page
     Then I should see "Bear River Health Department"
     When I route it to Davis County
     Then I should see "Unable to route CMR"
      And I should see "Onset date must be on or before"
      And I should see "A user with update privileges will need to fix the event."

  Scenario: Routing an contact event that has become invalid
    Given I am logged in as a super user
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And there is a contact on the event named Jones
      And the contact disease diagnosed date is invalid
     When I am on the contact show page
      And I route it to Bear River
     Then I should see "Unable to route CMR"
      And I should see "Date diagnosed must be on or after"
      And I should see "There were problems with the following fields"
      And I should get a 400 response

  Scenario: Internally routing an invalid event
    Given I am logged in as a super user
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And the event is routed to "Bear River"
      And the event disease onset date is invalid
     When I am on the CMR show page
      And I "Accept" the routed event
     Then I should see "Unable to change state of CMR"
      And I should see "Onset date must be on or before"
      And I should see "There were problems with the following fields"
      And I should get a 400 response

  Scenario: Internally routing an invalid event with a user that can't update
    Given I am logged in as a super user
      And I am not able to update events
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And the event is routed to "Bear River"
      And the event disease onset date is invalid
     When I am on the CMR show page
      And I "Accept" the routed event
     Then I should see "Unable to change state of CMR"
      And I should see "A user with update privileges will need to fix the event."

  Scenario: Internally routing an invalid contact event
    Given I am logged in as a super user
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And there is a contact on the event named Jones
      And the contact is routed to "Bear River"
      And the contact disease diagnosed date is invalid
     When I am on the contact show page
      And I "Accept" the routed event
     Then I should see "Unable to change state of CMR"
      And I should see "Date diagnosed must be on or after"
      And I should see "There were problems with the following fields"
      And I should get a 400 response

  Scenario: Displays the latest brief note when routing event
   Given I am logged in as a super user
   And a morbidity event exists in Bear River with the disease African Tick Bite Fever
   And the event is routed to "Bear River"
   And a brief note exists with text 'Latest note'

   When I navigate to the event show page
   And I click the "Route to Local Health Depts." link

   Then I should see 'Latest note' in Brief Note textbox

  Scenario: Displays the latest brief note in Status column
   Given I am logged in as a super user
   And a morbidity event exists in Bear River with the disease African Tick Bite Fever
   And the event is routed to "Bear River"
   And a brief note exists with text 'New note'

   When I navigate to the event show page

   Then I should see "New note"
