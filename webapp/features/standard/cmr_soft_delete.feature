Feature: Deleting a CMR

  Because Morbidity events sometimes need to be deleted
  but investigators are concerned about losing important data
  a Morbidity event can be deleted, but it is a soft delete.

  Scenario: Deleting a Morbidity event
    Given I am logged in as a super user
      And a morbidity event exists with the disease Mumps
    When I go to the show CMR page
      And I follow "Delete"
    Then I should see "The event was successfully marked as deleted."
      And the CMR should look deleted
      And I should not see the 'Delete' link

  Scenario: Deleting a Morbidity event that has a contact
    Given I am logged in as a super user
      And a morbidity event exists with the disease Mumps
      And the morbidity event has the following contacts:
        | last_name  | first_name |
        | Davis      | Miles      |
    When I go to the show CMR page
      And I follow "Delete"
    Then I should see "The event was successfully marked as deleted."
      And the CMR should look deleted
      And I should not see the 'Delete' link
      And contact "Davis, Miles" should appear deleted

  Scenario: Deleting a Morbidity event that has a place exposure
    Given I am logged in as a super user
      And a morbidity event exists with the disease Mumps
      And the morbidity event has the following place exposures:
        | name             |
        | Allen Scrap      |
    When I go to the show CMR page
      And I follow "Delete"
    Then I should see "The event was successfully marked as deleted."
      And the CMR should look deleted
      And I should not see the 'Delete' link
      And place exposure "Allen Scrap" should appear deleted