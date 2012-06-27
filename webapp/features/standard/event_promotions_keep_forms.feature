Feature: Forms from promoted events continue to work

  So that I can continue to use assigned forms
  As an admin or investigator
  I want to assigned forms to be available after event promotion


  Scenario: Contact event of a assessment event is promoted to morbidity event
    Given I am logged in as a super user
      And a contact event form named Mumps Form 1 (mumps1) exists for the disease Mumps
      And that form has core field configs configured for all core fields
      And that form is published
      And a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
      And there is a contact on the event named Jones
     When I am on the contact event edit page
      And I answer all core field config questions
      And I save the event
     Then I should see all of the core field config questions
      And I should see all core field config answers
     When I promote Jones to a assessment event
     Then I should see all of the promoted core field config questions
      And I should see all promoted core field config answers

  Scenario: Contact event of a morbidity event is promoted to morbidity event
    Given I am logged in as a super user
      And a contact event form named Mumps Form 1 (mumps1) exists for the disease Mumps
      And that form has core field configs configured for all core fields
      And that form is published
      And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And there is a contact on the event named Jones
     When I am on the contact event edit page
      And I answer all core field config questions
      And I save the event
     Then I should see all of the core field config questions
      And I should see all core field config answers
     When I promote Jones to a morbidity event
     Then I should see all of the promoted core field config questions
      And I should see all promoted core field config answers


  Scenario: Contact event of a assessment event is promoted to assessment event
    Given I am logged in as a super user
      And a contact event form named Mumps Form 1 (mumps1) exists for the disease Mumps
      And that form has core field configs configured for all core fields
      And that form is published
      And a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
      And there is a contact on the event named Jones
     When I am on the contact event edit page
      And I answer all core field config questions
      And I save the event
     Then I should see all of the core field config questions
      And I should see all core field config answers
     When I promote Jones to a assessment event
     Then I should see all of the promoted core field config questions
      And I should see all promoted core field config answers

  Scenario: Assessment event is promoted to morbidity event
    Given I am logged in as a super user
      And a assessment event form named Mumps Form 1 (mumps1) exists for the disease Mumps
      And that form has core field configs configured for all core fields
      And that form is published
      And a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
     When I am on the assessment event edit page
      And I answer all core field config questions
      And I save the event
     Then I should see all of the core field config questions
      And I should see all core field config answers
     When I promote the assessment to a morbidity event
     Then I should see all of the promoted core field config questions
      And I should see all promoted core field config answers

