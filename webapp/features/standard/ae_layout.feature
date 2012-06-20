Feature: Form and data layouts for AEs

  To make it easier for Epi's to enter data and read data
  We need to make sure fields are in the best place

  Scenario: Editing the clinical tab
    Given I am logged in as a super user
      And an assessment event exists with the disease Mumps
     When I go to edit the AE
     Then I should see the pregnancy fields in the right place
      And I should see the mortality fields in the right place

  Scenario: Viewing the clinical tab
    Given I am logged in as a super user
      And an assessment event exists with the disease Mumps
     When I go to view the AE
     Then I should see the pregnancy data in the right place
      And I should see the mortality data in the right place
