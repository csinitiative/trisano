Feature: Reordering entities

  Background:
    Given I am logged in as a super user
      And a cmr exists
      And the morbidity event has the following contacts:
        | last_name |
        | OneContact     |
        | TwoContact    |
        | ThreeContact    |
      And there is a place on the event named OnePlace
      And there is a place on the event named TwoPlace
      And there is a place on the event named ThreePlace
      And the event has the following treatments:
        | treatment_name | default |
        | Leeches        | true    |
        | Whiskey        | true    |
        | Cornbread      | true    |
      And I am on the event edit page
    
  Scenario: Ordering treatments
    When I move the treatment "Cornbread" to the top
    And I move the treatment "Whiskey" up
    And I save and continue
    Then the treatments should be ordered Cornbread, Whiskey, Leeches
    When I move the treatment "Cornbread" to the bottom
    And I move the treatment "Whiskey" down
    And I save and continue
    Then the treatments should be ordered Leeches, Whiskey, Cornbread
    
  Scenario: Ordering contacts
    When I move the contact "ThreeContact" to the top
    And I move the contact "TwoContact" up
    And I save and continue
    Then the contacts should be ordered ThreeContact, TwoContact, OneContact
    When I move the contact "ThreeContact" to the bottom
    And I move the contact "TwoContact" down
    And I save and continue
    Then the contacts should be ordered OneContact, TwoContact, ThreeContact

  Scenario: Ordering places
    When I move the place "ThreePlace" to the top
    And I move the place "TwoPlace" up
    And I save and continue
    Then the contacts should be ordered ThreePlace, TwoPlace, OnePlace
    When I move the contact "ThreePlace" to the bottom
    And I move the contact "TwoPlace" down
    And I save and continue
    Then the contacts should be ordered OnePlace, TwoPlace, ThreePlace
