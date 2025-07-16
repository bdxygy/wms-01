@owner
Feature: Owner capabilities

  Background:
    Given I am authenticated as an "OWNER"

  Scenario Outline: Owner CRUD Stores
    When I <operation> a store with valid payload
    Then the store <result>
    And I can see <visibility> the store in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |
      | delete    | is soft-deleted | list only |

  Scenario Outline: Owner CRUD Users
    When I <operation> a <role> user
    Then the user <result>
    And I can see <visibility> the user in the list and detail view
    Examples:
      | operation | role    | result     | visibility |
      | create    | ADMIN   | is created | both       |
      | create    | STAFF   | is created | both       |
      | create    | CASHIER | is created | both       |
      | read      | ADMIN   | is retrieved | both     |
      | update    | STAFF   | is updated | both       |
      | delete    | CASHIER | is soft-deleted | list only |

  Scenario Outline: Owner CRUD Categories
    When I <operation> a category
    Then the category <result>
    And I can see <visibility> the category in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |
      | delete    | is soft-deleted | list only |

  Scenario Outline: Owner CRUD Products
    When I <operation> a product
    Then the product <result>
    And I can see <visibility> the product in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |
      | delete    | is soft-deleted | list only |

  Scenario Outline: Owner CRUD Transactions
    When I <operation> a transaction of type "<type>"
    Then the transaction <result>
    And I can see <visibility> it in the list and detail view
    Examples:
      | operation | type    | result          | visibility |
      | create    | TRANSFER| is created      | both       |
      | create    | SALE    | is created      | both       |
      | read      | SALE    | is retrieved    | both       |
      | update    | TRANSFER| is updated      | both       |
      | delete    | SALE    | is soft-deleted | list only  |

  Scenario: Owner views store analytics
    When I open the analytics dashboard for store "Store-A"
    Then I see in/out items, total revenue and gross profit

  Scenario: Owner views cross-store analytics
    When I open the global analytics dashboard
    Then I see aggregated metrics across all stores

  Scenario: Owner views product check list per store
    When I navigate to the product check page for store "Store-A"
    Then I see two lists: "PENDING" and "OK"

  Scenario: Owner scans barcode to mark as checked
    Given a product exists with barcode "1234567890"
    When I scan barcode "1234567890" in store "Store-A"
    Then the product moves from "PENDING" to "OK"

@admin
Feature: Admin capabilities

  Background:
    Given I am authenticated as an "ADMIN"
    And I work under "Owner-1"
    And I can access all stores owned by "Owner-1" (Store-A, Store-B, Store-C)

  Scenario Outline: Admin CRU Users (only STAFF)
    When I <operation> a "STAFF" user
    Then the user <result>
    And I can see <visibility> the user in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |

  Scenario Outline: Admin CRU Categories
    When I <operation> a category
    Then the category <result>
    And I can see <visibility> the category in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |

  Scenario Outline: Admin CRU Products
    When I <operation> a product
    Then the product <result>
    And I can see <visibility> the product in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |

  Scenario Outline: Admin CRU Transactions
    When I <operation> a transaction of type "<type>"
    Then the transaction <result>
    And I can see <visibility> it in the list and detail view
    Examples:
      | operation | type    | result        | visibility |
      | create    | TRANSFER| is created    | both       |
      | create    | SALE    | is created    | both       |
      | read      | SALE    | is retrieved  | both       |
      | update    | TRANSFER| is updated    | both       |

  Scenario: Admin views product check list for any owner store
    When I open the product check page for any store owned by "Owner-1"
    Then I see the "PENDING" and "OK" lists for that store

  Scenario: Admin scans barcode to mark as checked in any owner store
    Given a product exists with barcode "1234567890" in any store owned by "Owner-1"
    When I scan barcode "1234567890" in that store
    Then the product moves from "PENDING" to "OK"

@staff
Feature: Staff capabilities

  Background:
    Given I am authenticated as a "STAFF"
    And I work under "Owner-1"
    And I can access all stores owned by "Owner-1" (Store-A, Store-B, Store-C)

  Scenario: Staff views stores list
    When I open the dashboard page
    Then I see all stores owned by "Owner-1" (Store-A, Store-B, Store-C)

  Scenario: Staff select store from store list
    When I open the Store list page
    Then I can choose any store owned by "Owner-1" (Store-A, Store-B, or Store-C)

  Scenario: Staff views product check list for any owner store
    When I open the product check page for any store owned by "Owner-1"
    Then I see the "PENDING" and "OK" lists for that store

  Scenario: Staff scans barcode to mark as checked in any owner store
    Given a product exists with barcode "1234567890" in any store owned by "Owner-1"
    When I scan barcode "1234567890" in that store
    Then the product moves from "PENDING" to "OK"

@cashier
Feature: Cashier capabilities

  Background:
    Given I am authenticated as a "CASHIER"
    And I work under "Owner-1"
    And I can access all stores owned by "Owner-1" (Store-A, Store-B, Store-C)

  Scenario: Cashier views transaction dashboard
    When I open the dashboard page
    Then I see transaction tab for all stores owned by "Owner-1"

  Scenario: Cashier selects store for transactions
    When I open the transaction dashboard
    Then I can choose any store owned by "Owner-1" to create SALE transactions

  Scenario Outline: Cashier CRU Transactions of type SALE at any owner store
    When I <operation> a transaction of type "SALE" at any store owned by "Owner-1"
    Then the transaction <result>
    And I can see <visibility> it in the list and detail view for that store
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |