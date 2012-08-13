Feature: Editing hep b specific fields

  In order to track hep b mothers so they know when and where to send HBIG
  Epi's need to be able to enter delivery dates and locations into a CMR

  @flush_core_fields_cache
  Scenario: Editing expected delivery data on a Hepatitis B Pregnancy Event
    Given I am logged in as a super user
      And disease "Hepatitis B Pregnancy Event" exists
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
     When I am on the morbidity event edit page
      And I complete the expected delivery facility fields
      And I save and continue
     Then I should see the expected delivery facility data
     When I remove the expected delivery data
     Then I should see the expected delivery facility fields
     When I search for an expected delivery facility
      And I select an expected delivery facility from the list
     Then I should see the expected delivery facility data

  @flush_core_fields_cache
  Scenario: Editing actual delivery data on a Hepatitis B Pregnancy Event
    Given I am logged in as a super user
      And disease "Hepatitis B Pregnancy Event" exists
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
     When I am on the morbidity event edit page
      And I complete the actual delivery facility fields
      And I save and continue
     Then I should see the actual delivery data
      And I should see the actual delivery date field
     When I remove the actual delivery data
     Then I should see the actual delivery facility fields
      And I should see the actual delivery date field
     When I search for an actual delivery facility
      And I select an actual delivery facility from the list
     Then I should see the actual delivery data
      And I should see the actual delivery date field

  @flush_core_fields_cache
  Scenario: Selecting an expected delivery facility on an event
    Given I am logged in as a super user
      And disease "Hepatitis B Pregnancy Event" exists
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
      And there is an expected delivery facility named "New Expected Delivery Facility"
     When I am on the morbidity event edit page
      And I search for an expected delivery facility
      And I select an expected delivery facility from the list
     Then I should see the expected delivery facility data

  @flush_core_fields_cache
  Scenario: Selecting an actual delivery facility on an event
    Given I am logged in as a super user
      And disease "Hepatitis B Pregnancy Event" exists
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
      And there is an actual delivery facility named "New Actual Delivery Facility"
     When I am on the morbidity event edit page
      And I search for an actual delivery facility
      And I select an actual delivery facility from the list
     Then I should see the actual delivery data

  @flush_core_fields_cache
  Scenario: Updating an actual delivery facility should not reset date
    Given I am logged in as a super user
     And disease "Hepatitis B Pregnancy Event" exists
     And a morbidity event exists with the disease Hepatitis B Pregnancy Event
     And "Hepatitis B Pregnancy Event" has disease specific core fields
     And there is an actual delivery facility named "New Actual Delivery Facility"
    When I am on the morbidity event edit page
     And I fill in the actual delivery date
     And I search for an actual delivery facility
     And I select an actual delivery facility from the list
    Then I should see the actual delivery date filled in
     And I should see the actual delivery data

  @flush_core_fields_cache
  Scenario: Removing an actual delivery facility in the same session it was added
    Given I am logged in as a super user
      And disease "Hepatitis B Pregnancy Event" exists
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
     When I am on the morbidity event edit page
      And I search for an actual delivery facility
      And I select an actual delivery facility from the list
     Then I should see the actual delivery data
     When I remove the actual delivery data
     Then I should see the actual delivery facility fields
