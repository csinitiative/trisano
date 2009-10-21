Feature: Edit short names on form questions

  To support avr features, it is sometimes necessary to go back and
  fix short names on questions, even after a form has been published.

  Scenario: Navigate to the short name edit screen
    Given I am logged in as a super user
      And a "morbidity" event form named "Cuke" with the following questions:
        | Question | Short name | Data type        |
        | Who?     | who        | single_line_text |
        | What?    | what       | single_line_text |
        | Where?   | where      | single_line_text |
       And that form is published
    When I go to the "Cuke" form details page
      And I follow "Fix short names"
    Then I should be on the form's edit questions page (version 1)
      And I should see "Who?"
      And I should see "What?"
      And I should see "Where?"

  Scenario: Change a short name
    Given I am logged in as a super user
      And a "morbidity" event form named "Cuke" with the following questions:
        | Question | Short name | Data type        |
        | Who?     | who        | single_line_text |
        | What?    | what       | single_line_text |
        | Where?   | where      | single_line_text |
       And that form is published
     When I go to the form's edit questions page (version 1)
       And I change the "Who?" question's short name to "who do voodoo"
       And I press "Update"
     Then I should see "Form questions were successfully updated"
       And I should be on the form's show questions page (version 1)
       And I should see "who_do_voodoo"

