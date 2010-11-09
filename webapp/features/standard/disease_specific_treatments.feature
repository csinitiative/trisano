Feature: Treatments listed by disease

  Background:
    Given I am logged in as a super user
      And the following treatments:
        | treatment_name | active | default |
        | Shot           | true   | true    |
        | Beer           | true   | true    |
        | Placebo        | true   | false   |

  Scenario: A new event lists the default treatments
    When I navigate to the new event page
    Then I should see a treatment select
     And I should see the following treatment options:
       | treatment_name |
       | Shot           |
       | Beer           |
     And I should not see the following treatment options:
       | treatment_name |
       | Placebo        |
