Feature: Treatments listed by disease

  Background:
    Given I am logged in as a super user
      And the following treatments:
        | treatment_name | active | default |
        | Shot           | true   | true    |
        | Beer           | true   | true    |
        | Placebo        | true   | false   |

  Scenario: A new event lists the default treatments
    When I navigate to the new morbidity event page
    Then I should see a treatment select
     And I should see the following treatment options:
       | treatment_name |
       | Shot           |
       | Beer           |
     And I should not see the following treatment options:
       | treatment_name |
       | Placebo        |

  Scenario: Event treatment selects are based on the event's disease
    Given disease "The Trots" exists
      And a morbidity event exists with the disease The Trots
      And the following treatments associated with the disease "The Trots":
        | treatment_name | active | default |
        | Water Joe      | true   | false   |
     When I go to edit the cmr
     Then I should see the following treatment options:
        | treatment_name |
        | Water Joe      |
      And I should not see the following treatment options:
        | treatment_name |
        | Shot           |
        | Beer           |
