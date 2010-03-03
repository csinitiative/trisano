Feature: Localized date picker

  In order to allow the date picker to be used in different locales
  As a user
  I need to be able to submit and view localized dates using the date picker

  Scenario: Editing and viewing dates in the default locale (en)
    Given I am logged in as a super user
      And a basic morbidity event exists
    When I go to edit the CMR
      And I fill in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date" with "January 12, 2001"
      And I save the edit event form
    Then I should see "2001-01-12"

    And I should see "Sun Mon Tue Wed Thu Fri Sat"
    And I should see "January February March April May June July August September October November December"

    When I go to edit the CMR
    Then I should see "January 12, 2001"

    When I fill in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date" with "Jan 13, 2001"
      And I save the edit event form
    Then I should see "2001-01-13"

    When I go to edit the CMR
    Then I should see "January 13, 2001"

    When I fill in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date" with "jan 14, 2001"
      And I save the edit event form
    Then I should see "2001-01-14"

    When I go to edit the CMR
    Then I should see "January 14, 2001"

    When I fill in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date" with "january 15, 2001"
      And I save the edit event form
    Then I should see "2001-01-15"

    When I go to edit the CMR
    Then I should see "January 15, 2001"


  Scenario: Editing and viewing dates in the test locale
    Given I am logged in as a super user
      And a basic morbidity event exists
      And I have selected the "Test" locale

    When I go to edit the CMR
      And I fill in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date" with "janvier 12, 2001"
      And I save the edit event form
    Then I should see "12/01/2001"

    And I should see "dim lun mar mer jeu ven sam"
    And I should see "Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre"

    When I go to edit the CMR
    Then I should see "Janvier 12, 2001"

    When I fill in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date" with "Jan 13, 2001"
      And I save the edit event form
    Then I should see "13/01/2001"

    When I go to edit the CMR
    Then I should see "Janvier 13, 2001"

    When I fill in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date" with "jan 14, 2001"
      And I save the edit event form
    Then I should see "14/01/2001"

    When I go to edit the CMR
    Then I should see "Janvier 14, 2001"

    When I fill in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_birth_date" with "Janvier 15, 2001"
      And I save the edit event form
    Then I should see "15/01/2001"

    When I go to edit the CMR
    Then I should see "Janvier 15, 2001"