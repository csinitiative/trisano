Feature: Printer friendly morbidity events

  To better be able to review cases
  An ivestigator
  Needs to be able to print cmrs out in a readable format

  Scenario: Printing only one section
    Given I am logged in as a super user
    And a morbidity event exists with the disease Mumps
    And the morbidity event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |

    When I navigate to the event show page
    And I choose to print "Demographic" data
    And I press "Print"

    Then I should see the following sections:
      |section    |
      |Demographic|

    And I should not see the following sections
      |section        |
      |Clinical       |
      |Laboratory     |
      |Contacts       |
      |Encounters     |
      |Epidemiological|
      |Reporting      |
      |Investigation  |
      |Notes          |
      |Administrative |

  Scenario: Printing multiple sections
    Given I am logged in as a super user
    And a morbidity event exists with the disease Mumps
    And the morbidity event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |

    When I navigate to the event show page
    And I choose to print "Demographic" data
    And I choose to print "Clinical" data
    And I press "Print"

    Then I should see the following sections:
      |section    |
      |Demographic|
      |Clinical   |

    And I should not see the following sections
      |section        |
      |Laboratory     |
      |Contacts       |
      |Encounters     |
      |Epidemiological|
      |Reporting      |
      |Investigation  |
      |Notes          |
      |Administrative |

  Scenario: Printing all sections the hard way
    Given I am logged in as a super user
    And a morbidity event exists with the disease Mumps
    And the morbidity event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |

    When I navigate to the event show page
    And I choose to print "Demographic" data
    And I choose to print "Clinical" data
    And I choose to print "Laboratory" data
    And I choose to print "Contacts" data
    And I choose to print "Encounters" data
    And I choose to print "Epidemiological" data
    And I choose to print "Reporting" data
    And I choose to print "Investigation" data
    And I choose to print "Administrative" data
    And I press "Print"

    Then I should see the following sections:
      |section        |
      |Demographic    |
      |Clinical       |
      |Laboratory     |
      |Contacts       |
      |Encounters     |
      |Epidemiological|
      |Reporting      |
      |Investigation  |
      |Administrative |

    And I should not see the following sections
      |Notes          |

  Scenario: Printing all sections the easy way
    Given I am logged in as a super user
    And a morbidity event exists with the disease Mumps
    And the morbidity event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |

    When I navigate to the event show page
    And I choose to print "All" data
    And I press "Print"

    Then I should see the following sections:
      |section        |
      |Demographic    |
      |Clinical       |
      |Laboratory     |
      |Contacts       |
      |Encounters     |
      |Epidemiological|
      |Reporting      |
      |Investigation  |
      |Administrative |
      |Notes          |

  Scenario: Printing a morbidity event should print any associated Contact events
    Given I am logged in as a super user
    And a morbidity event exists with the disease Mumps
    And the morbidity event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |
      |Abbot    |Bud       |

    When I print the morbidity event with "All"

    Then I should see "Miles" under contact reports
    And I should see "Davis" under contact reports
    And I should see "Bud" under contact reports
    And I should see "Abbot" under contact reports

  Scenario: Printing a morbidity event should not print deleted Contact events
    Given I am logged in as a super user
    And a morbidity event exists with the disease Mumps
    And the morbidity event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |
    And the morbidity event has the following deleted contacts:
      |last_name|first_name|
      |Abbot    |Bud       |
  
    When I print the morbidity event with "All"

    Then I should see "Miles" under contact reports
    And I should see "Davis" under contact reports
    And I should not see "Bud" under contact reports
    And I should not see "Abbot" under contact reports

      
