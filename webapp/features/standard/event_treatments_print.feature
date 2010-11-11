Features: Printing events with treatments

  Background:
    Given I am logged in as a super user

  Scenario: Printing events with treatments
    Given a simple morbidity event for last name "Smoker"
    And the morbidity event has the following contacts:
    | last_name | first_name |
    | Davis     | James      |
    And the following treatments exist
    | treatment_name | active | default |
    | Rubbings       | true   | true    |
    | Foot massage   | true   | true    |
    | Leeches        | true   | true    |
    When I go to edit the CMR
    And I select "Rubbings" from "morbidity_event_interested_party_attributes_treatments_attributes_0_treatment_id"
    And I save the event
    And I choose to print "All" data
    And I press "Print"
    Then I should see "Rubbings"

    When I go to edit the CMR
    When I follow "Edit Contact"
    And I select "Rubbings" from "contact_event_interested_party_attributes_treatments_attributes_0_treatment_id"
    And I save the contact event
    And I choose to print "All" data
    And I press "Print"
    Then I should see "Rubbings"



