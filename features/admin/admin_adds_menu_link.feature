@javascript
Feature: Admin adds menu link

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And I am on the top bar admin page

  Scenario: Admin adds menu link
    When I follow "Add a new link to menu"
    And I fill in "menu_links[menu_link_attributes][jsnew-1][translation_attributes][en][title]" with "Yelo Blog"
    And I fill in "menu_links[menu_link_attributes][jsnew-1][translation_attributes][en][url]" with "https://jungleworks.com/yelo/rentals-guide/"
    And I fill in "menu_links[menu_link_attributes][jsnew-1][translation_attributes][fi][title]" with "Yelo Blogi"
    And I fill in "menu_links[menu_link_attributes][jsnew-1][translation_attributes][fi][url]" with "https://jungleworks.com/yelo/rentals-guide/"
    And I press submit
    Then I should see "Details updated"
    When I open the menu
    Then I should see "Yelo Blog" on the menu
