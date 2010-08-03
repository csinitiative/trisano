Feature: Select options specific to Hepatitis B Pregnancy Event

  To provide a better user experience and improved data integrity,
  drop down selections are limited to options that are appropriate for
  the Hep B Pregnancy Event.

  Scenario: Contact disposition selection on a CMR
    Given I am logged in as a super user
      And the hep b disease specific selections are loaded
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
     When I go to edit the CMR
     Then I should see only these contact disposition select options:
       | content                 |
       |                         |
       | Provider refusal        |
       | Mother/family refusal   |
       | False positive mother   |
       | Infant adopted          |
       | Infant died             |
       | Miscarriage/termination |
       | Completed               |
       | Active follow up        |
       | Out of jurisdiction     |
