Feature: Localized unassigned jurisdiction

  As a user I should see a localized Unassigned Jurisdiction name

  Scenario: Viewing Unassigned Jurisdiction names in the test locale
    Given I am logged in as a super user
      And a simple morbidity event in jurisdiction Unassigned for last name Wilson
      And I have selected the "Test" locale
    When I follow "xEVENTS"
      Then I should see "xUnassigned"
    When I follow "xEdit"
      Then I should see "xUnassigned"
    When I follow "xSEARCH"
      Then I should see "xUnassigned"
    # Uncomment when Webrat can handle our search
    #When I fill in "name" with "Wilson"
    #  And I submit the search
    #Then I should see "xUnassigned" in the search results

