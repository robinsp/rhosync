Feature: Sync Smoke Test
  In order to avoid submitting patches with simple, yet fatal, errors 
  the Integrator
  would like contributors to run a simple smoke test
  
  # The initial author of this feature was guilty of such an error
  # and is now making amends. :-) 
  
  Scenario: Sync Products from the remote Store application
    Given a clean database
    And sample source adapters loaded from fixtures
    Then database has no "ObjectValues"
    
    When I go to the homepage
    And I fill in "login" with "admin" 
    And I fill in "password" with "password"
    And I press "Log in"
    Then I should see a link to "Store"
    
    When I follow "Store" 
    Then I should see a link to "Product"
    And I should see a link to "Customer"
    
    When I follow "Product"
    And I follow "Show records" 
    Then I should see a non-empty table of "Product" objects
