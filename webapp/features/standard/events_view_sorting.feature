Feature: Ordering the events view by column

  Scenario: Sorting events by patient name
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Bear River for last name Abernathy
      And a simple morbidity event in jurisdiction Bear River for last name Benson
      And a simple morbidity event in jurisdiction Bear River for last name Cleveland
    When I visit the events index page
      And I follow "Patient Name"
    Then the "Abernathy" event should come before the "Benson" event
      And the "Benson" event should come before the "Cleveland" event
    When I follow "Patient Name"
    Then the "Cleveland" event should come before the "Benson" event
      And the "Benson" event should come before the "Abernathy" event

  Scenario: Sorting events by disease
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Bear River, last name Cleveland, and disease African Tick Bite Fever
      And a simple morbidity event in jurisdiction Bear River, last name Benson, and disease Beaver Bite Fever
      And a simple morbidity event in jurisdiction Bear River, last name Abernathy, and disease Cat Scratch Fever
    When I visit the events index page
      And I follow "Disease"
    Then the "Cleveland" event should come before the "Benson" event
      And the "Benson" event should come before the "Abernathy" event
    When I follow "Disease"
    Then the "Abernathy" event should come before the "Benson" event
      And the "Benson" event should come before the "Cleveland" event

  Scenario: Sorting events by jurisdiction
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Bear River, last name Cleveland, and disease African Tick Bite Fever
      And a simple morbidity event in jurisdiction Central Utah, last name Benson, and disease Beaver Bite Fever
      And a simple morbidity event in jurisdiction Weber-Morgan, last name Abernathy, and disease Cat Scratch Fever
    When I visit the events index page
      And I follow "Jurisdiction"
    Then the "Cleveland" event should come before the "Benson" event
      And the "Benson" event should come before the "Abernathy" event
    When I follow "Jurisdiction"
    Then the "Abernathy" event should come before the "Benson" event
      And the "Benson" event should come before the "Cleveland" event

  Scenario: Sorting events by status
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Bear River, last name Cleveland, and disease African Tick Bite Fever
      And the morbidity event state workflow state is "closed"
      And a simple morbidity event in jurisdiction Bear River, last name Benson, and disease Beaver Bite Fever
      And the morbidity event state workflow state is "new"
      And a simple morbidity event in jurisdiction Bear River, last name Abernathy, and disease Cat Scratch Fever
      And the morbidity event state workflow state is "under_investigation"
    When I visit the events index page
      And I follow "Status"
    Then the "Cleveland" event should come before the "Benson" event
      And the "Benson" event should come before the "Abernathy" event
    When I follow "Status"
    Then the "Abernathy" event should come before the "Benson" event
      And the "Benson" event should come before the "Cleveland" event

  Scenario: Sorting events by event date
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Bear River for last name Abernathy
      And the morbidity event was created 3 days ago
      And a simple morbidity event in jurisdiction Bear River for last name Benson
      And the morbidity event was created 2 days ago
      And a simple morbidity event in jurisdiction Bear River for last name Cleveland
      And the morbidity event was created 1 day ago
    When I visit the events index page
      And I follow "Event Created"
    Then the "Cleveland" event should come before the "Benson" event
      And the "Benson" event should come before the "Abernathy" event
    When I follow "Event Created"
    Then the "Abernathy" event should come before the "Benson" event
      And the "Benson" event should come before the "Cleveland" event
