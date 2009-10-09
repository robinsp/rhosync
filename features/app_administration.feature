Feature: App Administration
  In order to provide sync services for multiple applications 
  a User
  uses the admin interface to configure applications 
  
  Scenario: Set up an address book App to synchronize a Person object 
    Given I'm logged in as "AppOwner"
    And I should not see an application list
    
    When I follow "Create new app"
    And I fill in "Name" with "AddressBookApp"
    And I fill in "Description" with "Contact sync"
    And I press "Create"
    Then I should see the following applications: 
    |AddressBookApp|
