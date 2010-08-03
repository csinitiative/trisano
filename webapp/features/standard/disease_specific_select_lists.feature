Feature: Drop down lists with content driven by the disease event

  Since all selections aren't appropriate for all situations, allow
  drop down lists to be driven by disease event

  Scenario: Disease specific items to a select list
    Given I am logged in as a super user
      And a morbidity event exists with the disease African Tick Bite Fever
      And disease "African Tick Bite Fever" has the disease specific "Contact Disposition Type" options:
        | code_description         | the_code |
        | Fell Through a Worm Hole | FTWH     |
        | Angry at Life            | AAL      |
     When I go to edit the CMR
     Then I should see all of the default "Contact Disposition Type" options
      And I should see these select options:
        | text                     |
        | Fell Through a Worm Hole |
        | Angry at Life            |

  Scenario: Disease specific items to a multi-select list
    Given I am logged in as a super user
      And a morbidity event exists with the disease African Tick Bite Fever
      And disease "African Tick Bite Fever" has the disease specific "Race" options:
        | code_description | the_code |
        | Hobbit           | HOB      |
        | Ent              | ENT      |
     When I go to edit the CMR
     Then I should see all of the default "Race" options
      And I should see these select options:
        | text   |
        | Hobbit |
        | Ent    |

  Scenario: Disease specific select items shouldn't appear on other diseases
    Given I am logged in as a super user
      And a morbidity event exists with the disease Dengue
      And disease "African Tick Bite Fever" has the disease specific "Contact Disposition Type" options:
        | code_description         | the_code |
        | Fell Through a Worm Hole | FTWH     |
        | Angry at Life            | AAL      |
     When I go to edit the CMR
     Then I should see all of the default "Contact Disposition Type" options
      And I should not see these select options:
        | text                     |
        | Fell Through a Worm Hole |
        | Angry at Life            |

  Scenario: Hiding 'core' selects for specific diseases
    Given I am logged in as a super user
      And a morbidity event exists with the disease Dengue
      And disease "Dengue" hides these "Contact Disposition Type" options:
        | code_description                      | the_code |
        | Not infected                          | NI       |
        | Preventative treatment                | PT       |
        | Located, refused exam and/or treament | LR       |
     When I go to edit the CMR
     Then I should not see these select options:
       | text                                  |
       | Not infected                          |
       | Preventative treatment                |
       | Located, refused exam and/or treament |
