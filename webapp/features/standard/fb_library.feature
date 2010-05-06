Feature: Questions can be stored in a library

  Scenario: Copying questions to the library
    Given I am logged in as a super user
      And I already have a published form
      And that form has one question on the default view
     When I copy the question to the library root
     Then I should get a 200 response
      And the question should appear under no group in the library

  Scenario: Copying questions to a library group
    Given I am logged in as a super user
      And I already have a published form
      And that form has one question on the default view
      And I have a library group named "Awesome questions"
     When I copy the question to the library group "Awesome questions"
     Then I should get a 200 response
      And the question is in the library group
