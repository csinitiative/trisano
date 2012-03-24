Feature: Select options specific to Hepatitis B Pregnancy Event

  To provide a better user experience and improved data integrity,
  drop down selections are limited to options that are appropriate for
  the Hep B Pregnancy Event.

  Scenario: Contact disposition selection on a CMR
    Given I am logged in as a super user
      And the hep b disease specific selections are loaded
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
     When I go to edit the CMR
     Then I should see only these disposition select options:
        | content                    |
        |                            |
        | Active follow up           |
        | Completed                  |
        | Provider refusal           |
        | Mother/family refusal      |
        | Moved                      |
        | Unable to locate           |
        | Adopted                    |
        | Died                       |
        | False positive mother/case |
        | Miscarriage/termination    |
        | Other                      |

  Scenario: Contact disposition selection on a Contact event
    Given I am logged in as a super user
      And the hep b disease specific selections are loaded
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And the morbidity event has the following contacts:
        | last_name |
        | Chandler  |
     When I go to the first CMR contact's edit page
     Then I should see only these disposition select options:
        | content                    |
        |                            |
        | Active follow up           |
        | Completed                  |
        | Provider refusal           |
        | Mother/family refusal      |
        | Moved                      |
        | Unable to locate           |
        | Adopted                    |
        | Died                       |
        | False positive mother/case |
        | Miscarriage/termination    |
        | Other                      |

  Scenario: Contact type selection on a CMR
    Given I am logged in as a super user
      And the hep b disease specific selections are loaded
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
     When I go to edit the CMR
     Then I should see only these contact type select options:
        | content                   |
        |                           |
        | Infant                    |
        | Adult household           |
        | Child by case mother      |
        | Child by other mother     |
        | Non-spouse sexual contact |
        | Spouse sexual contact     |

  Scenario: Contact type selection on a Contact event
    Given I am logged in as a super user
      And the hep b disease specific selections are loaded
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And the morbidity event has the following contacts:
        | last_name |
        | Chandler  |
     When I go to the first CMR contact's edit page
     Then I should see only these contact type select options:
        | content                   |
        |                           |
        | Infant                    |
        | Adult household           |
        | Child by case mother      |
        | Child by other mother     |
        | Non-spouse sexual contact |
        | Spouse sexual contact     |
