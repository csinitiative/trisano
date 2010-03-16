Feature: Creating a question element on a form

  To facilitate creating custom forms
  Users need to be able to create question elements

  Scenario: Creating an invalid question element
    Given a morbidity event form exists
     When I create a question element with blank question text
     Then I should get a 400 response
      And I should see "Question text can't be blank"
