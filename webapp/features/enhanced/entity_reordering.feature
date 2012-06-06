Feature: Reordering entities

  Background:
    Given I am logged in as a super user
    And a cmr exists
    
  Scenario: Ordering treatments
    Given the event has the following treatments:
      | treatment_name | default |
      | Leeches        | true    |
      | Whiskey        | true    |
      | Cornbread      | true    |
    And I am on the morbidity event edit page
    When I move the treatment "Cornbread" to the top
    And I move the treatment "Whiskey" up
    And I save and continue
    Then the treatments should be ordered Cornbread, Whiskey, Leeches
    When I move the treatment "Cornbread" to the bottom
    And I move the treatment "Whiskey" down
    And I save and continue
    Then the treatments should be ordered Leeches, Whiskey, Cornbread
    
  Scenario: Ordering contacts
    Given the morbidity event has the following contacts:
      | last_name |
      | OneContact     |
      | TwoContact    |
      | ThreeContact    |
    And I am on the morbidity event edit page
    When I move the contact "ThreeContact" to the top
    And I move the contact "TwoContact" up
    And I save and continue
    Then the contacts should be ordered ThreeContact, TwoContact, OneContact
    When I move the contact "ThreeContact" to the bottom
    And I move the contact "TwoContact" down
    And I save and continue
    Then the contacts should be ordered OneContact, TwoContact, ThreeContact

  Scenario: Ordering places
    Given there is a place on the event named OnePlace
    And there is a place on the event named TwoPlace
    And there is a place on the event named ThreePlace
    And I am on the morbidity event edit page
    When I move the place "ThreePlace" to the top
    And I move the place "TwoPlace" up
    And I save and continue
    Then the contacts should be ordered ThreePlace, TwoPlace, OnePlace
    When I move the contact "ThreePlace" to the bottom
    And I move the contact "TwoPlace" down
    And I save and continue
    Then the contacts should be ordered OnePlace, TwoPlace, ThreePlace

  Scenario: Ordering lab results
    Given the event had the following lab results:
        | test_type  |
        | TestTypeOne |
        | TestTypeTwo |
        | TestTypeThree |
    And I am on the morbidity event edit page
    When I move the lab result "TestTypeThree" to the top
    And I move the place "TestTypeTwo" up
    And I save and continue
    Then the lab results should be ordered TestTypeThree, TestTypeTwo, TestTypeOne
    When I move the lab result "TestTypeThree" to the bottom
    And I move the lab result "TestTypeTwo" down
    And I save and continue
    Then the lab results should be ordered TestTypeOne, TestTypeTwo, TestTypeThree

  Scenario: Ordering labs without filling in lab info should not cause a validation error
    Given I am on the morbidity event edit page
    And I click the arrows on an empty lab result
    And I save and continue
    Then I should not see "There were problems with the following fields"
    And I should see "CMR was successfully updated."