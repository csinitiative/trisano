Features: Viewing and working with tasks via the calendar

  To provide better visibility into tasks
  Users can view and access tasks via the calendar

  Scenario: Viewing tasks on the calendar
    Given I am logged in as a super user
    And a morbidity event exists
    And the following tasks for the event
    | name | category | priority | status | due_date |
    | Visit the sick | Appointment | High | Pending | today |
    | Call the sick | Call Back | Medium  | Complete | today |
    | Treat the sick | Treatment | Low | Not applicable | today |
    | Treat the sick again | Treatment | Low | Not applicable | next month |

    When I am on the dashboard page
    And I follow "View on calendar"
    Then I should see "Visit the sick"
    And I should see "Call the sick"
    And I should see "Treat the sick"
    And I should not see "Treat the sick again"
    And the task "Visit the sick" should be styled as pending
    And the task "Call the sick" should be styled as complete
    And the task "Treat the sick" should be styled as not applicable

  Scenario: Clicking through to tasks on the calendar
    Given I am logged in as a super user
    And a morbidity event exists
    And the following tasks for the event
    | name | category | priority | status | due_date |
    | Visit the sick | Appointment | High | Pending | today |

    When I am on the calendar page
    And I follow "Visit the sick"
    Then I should see "Edit Task"
    And I should see "Visit the sick"
    When I follow "View on calendar"
    Then I should be on the calendar page

