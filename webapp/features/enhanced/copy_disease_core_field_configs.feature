Feature: Copying disease specific core field configurations to other diseases

  To simplify management of disease specific core field configurations
  As an admin
  I want to be able to copy a configuration to other, similar diseases

  Background:
    Given I am logged in as a super user
      And these diseases exist:
       | disease_name | active |
       | Lycanthropy  | true   |
       | Vampirism    | true   |
       | The Trots    | true   |

  Scenario: Copying a configuration to one other disease
    When I go to the diseases admin page
     And I follow the "Lycanthropy" disease Core Fields link
     And I hide a core field
     And I apply this configuration to "Vampirism"
     And I follow the "Vampirism" disease Core Fields link
    Then the "Vampirism" disease core field is hidden
