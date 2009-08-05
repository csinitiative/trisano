Feature: Managing Lab Results

  To accurately track a patient's illness
  A user needs to be able to enter lab results into the system

  Scenario: Selecting a test type in a new event
    Given I am logged in as a super user
    And the following common test types are in the system
      | Blood Test |
      | Urine Test |
      | X-Ray      |

    When I navigate to the new event page
    Then all common test types should be available for selection
    And the following common test types should not be available for selection
      |More choices... |

  Scenario: Selecting a test type in an existing event with no lab results and no disease
    Given I am logged in as a super user
    And the following disease to common test types mapping exists
      | disease_name | common_name |
      | AIDS         | Blood Test  |
      | AIDS         | Urine Test  |
      | Plague       | X-Ray       |
    And a simple morbidity event for last name Jones

    When I navigate to the event edit page
    Then the following common test types should be available for selection
      | Blood Test |
      | Urine Test |
      | X-Ray      |

    And the following common test types should not be available for selection
      | More choices... |

  Scenario: Selecting a test type in an existing event with no lab results but with a disease
    Given I am logged in as a super user
    And the following disease to common test types mapping exists
      | disease_name | common_name |
      | AIDS         | Blood Test  |
      | AIDS         | Urine Test  |
      | Plague       | X-Ray       |
    And a morbidity event exists with the disease AIDS

    When I navigate to the event edit page
    Then the following common test types should be available for selection
      | Blood Test      |
      | Urine Test      |
      | More choices... |

    And the following common test types should not be available for selection
      | X-Ray |

  Scenario: Selecting a test type in an existing event with an unmapped disease
    Given I am logged in as a super user
    And the following disease to common test types mapping exists
      | disease_name | common_name |
      | AIDS         | Blood Test  |
      | AIDS         | Urine Test  |
      | Plague       | X-Ray       |
    And a morbidity event exists with the disease Anthrax

    When I navigate to the event edit page
    Then the following common test types should be available for selection
      | Blood Test |
      | Urine Test |
      | X-Ray      |

    And the following common test types should not be available for selection
      | More choices... |

  Scenario: Selecting a test type in an existing event with one lab result
    Given I am logged in as a super user
    And the following disease to common test types mapping exists
      | disease_name | common_name |
      | AIDS         | Blood Test  |
      | AIDS         | Urine Test  |
      | Plague       | X-Ray       |
    And a morbidity event exists with a lab result having test type 'Blood Test'

    When I navigate to the event edit page
    Then the following common test types should be available for selection
      | Blood Test      |
      | More choices... |

    And the following common test types should not be available for selection
      | X-Ray      |
      | Urine Test |
