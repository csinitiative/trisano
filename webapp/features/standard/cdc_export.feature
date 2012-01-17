Feature: Exporting reportable diseases for the CDC

  Administrators need to be able send data to the CDC about a
  particular set of reportable diseases.

  Scenario: Exporting a new record to the CDC
    Given I am logged in as a super user
      And the disease "Brucellosis" with the cdc code "10020"
      And the disease "Brucellosis" exports to CDC when state is "Confirmed"
      And a morbidity event exists with the disease Brucellosis
      And the morbidity event state case status is "Confirmed"
    When I go to the CDC export for the current week
    Then I should see "V491002000001"
     And I should see "M 49#{Time.now.strftime('%g')}0(.*)10020"

  @pending
  Scenario: Exporting a deleted record that's already been sent to the CDC
    Given I am logged in as a super user
      And the disease "Brucellosis" with the cdc code "10020"
      And the disease "Brucellosis" exports to CDC when state is "Confirmed"
      And a morbidity event exists with the disease Brucellosis
      And the morbidity event state case status is "Confirmed"
      And the morbidity event was sent to the CDC
      And the morbidity event is deleted
    When I go to the CDC export for the current week
     And I should see "D 490"

