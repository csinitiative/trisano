Feature: Core fields for Hep B are labeled so they can be distinguished from other fields

  To simplify the user experience when updating help text or selection
  core fields from form builder, hep b fields are labeled to
  distinguish them from other core fields

  Scenario: Viewing core fields from the Help Text index page
    Given I am logged in as a super user
     When I go to view all core fields
     Then I should see the following:
        | text                                                       |
        | Area code (Perinatal Hep B, Expected delivery facility)    |
        | Phone number (Perinatal Hep B, Expected delivery facility) |
        | Extension (Perinatal Hep B, Expected delivery facility)    |
        | Area code (Perinatal Hep B, Actual delivery facility)      |
        | Phone number (Perinatal Hep B, Actual delivery facility)   |
        | Extension (Perinatal Hep B, Actual delivery facility)      |
        | Area code (Perinatal Hep B, Health care provider)          |
        | Phone number (Perinatal Hep B, Health care provider)       |
        | Extension (Perinatal Hep B, Health care provider)          |
        | First name (Perinatal Hep B, Health care provider)         |
        | Last name (Perinatal Hep B, Health care provider)          |
        | Middle name (Perinatal Hep B, Health care provider)        |

