Feature: Copying disease specific core field configurations to other diseases

  To simplify management of disease specific treatmentconfigurations
  As an admin
  I want to be able to copy a configuration to other, similar diseases

  Background:
    Given I am logged in as a super user
      And these diseases exist:
       | disease_name | active |
       | Lycanthropy  | true   |
       | Vampirism    | true   |
       | The Trots    | true   |
      And these treatments exist:
       | treatment_name | active | default |
       | Shot           | true   | true    |
       | Beer           | true   | true    |
       | Leeches        | true   | true    |
      And the disease "Vampirism" has the following treatments:
       | treatment_name |
       | Shot           |
       | Beer           |

  Scenario: Copying a configuration to one other disease
    When I go to the diseases admin page
     And I follow the "Vampirism" disease Treatments link
     And I apply this configuration to "Lycanthropy"
     And I go to the diseases admin page
     And I follow the "Lycanthropy" disease Treatments link
    Then I should see the following associated treatments:
       | treatment_name |
       | Shot           |
       | Beer           |
