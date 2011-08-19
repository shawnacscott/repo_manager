@announce
Feature: Configuration via yaml file

  In order to configure options the program should process configuration
  options via yaml. These options should override hard coded defaults but not
  command line options.

  Config files are read from multiple locations in order of priority.  Once a
  config file is found, all other config files are ignored. Priority:
  ["./repo.conf", "./.repo.conf", "./config/repo.conf", "~/.repo.conf"]

  All command line options can be read from the config file from the "options:"
  block. The "options" block is optional.  The "repos" block describes the repo
  names and attributes.  The "repos" block is required.  Commands that operate
  on repos will fail if the repos block is invalid or missing.

  NOTE: All file system testing is done via the Aruba gem.  The home folder
  config file is stubbed to prevent testing contamination in case it exists.

  Scenario: Specified config file exists
    Given an empty file named "config.conf"
    When I run `repo path --verbose --config=config.conf`
    Then the output should contain:
      """
      config file: config.conf
      """

  Scenario: Specified config file option but not given on command line
    When I run `repo path --verbose --config`
    Then the exit status should be 1
    And the output should contain:
      """
      missing argument: --config
      """

  Scenario: Specified config file not found
    When I run `repo path --verbose --config=config.conf`
    Then the exit status should be 1
    And the output should contain:
      """
      config file not found
      """

 Scenario: Reading options from specified config file, ignoring the
    default config file
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        coloring: true
      """
    And a file named "repo_no_coloring.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        coloring: false
      """
    When I run `repo path --verbose --config=repo_no_coloring.conf`
    Then the output should contain:
      """
      :coloring=>false
      """
    And the output should not contain:
      """
      :coloring=>true
      """

  Scenario: Reading options from specified config file, ignoring the
    default config file with override on command line
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        coloring: true
      """
    And a file named "repo_no_coloring.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        coloring: false
      """
    When I run `repo path --verbose --config=repo_no_coloring.conf --coloring`
    Then the output should contain:
      """
      :coloring=>"AUTO"
      """
    And the output should not contain:
      """
      :coloring=>false
      """
    And the output should not contain:
      """
      :coloring=>true
      """

 Scenario: Reading options from config file with negative override on command line
    And a file named "repo_with_coloring.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        coloring: true
      """
    When I run `repo path --verbose --config=repo_with_coloring.conf --no-coloring`
    Then the output should contain:
      """
      :coloring=>false
      """

  Scenario: Reading text options from config file
    Given a file named "repo_with_always_coloring.conf" with:
      """
      ---
      repos:
        test1:
          path: test 1/test path 1
        test2:
          path: test_path_2
      options:
        coloring: ALWAYS
      """
    When I run `repo path --verbose --config=repo_with_always_coloring.conf`
    Then the output should contain:
      """
      :coloring=>"ALWAYS"
      """

  Scenario: Reading default valid config files ordered by priority
    Given a file named "repo.conf" with:
      """
      ---
      repos:
        repo1:
          path: repo1
      """
    And a file named ".repo.conf" with:
      """
      ---
      repos:
        repo2:
          path: repo2
      """
    And a file named "config/repo.conf" with:
      """
      ---
      repos:
        repo3:
          path: repo3
      """
    When I run `repo list --listing=SHORT`
    Then the output should contain:
      """
      repo1: repo1
      """
    And the output should not contain:
      """
      repo2: repo2
      """
    And the output should not contain:
      """
      repo3: repo3
      """

  Scenario: Reading default config file '.repo.conf'
    Given a file named ".repo.conf" with:
      """
      ---
      repos:
        repo2:
          path: repo2
      """
    And a file named "config/repo.conf" with:
      """
      ---
      repos:
        repo3:
          path: repo3
      """
    When I run `repo list --listing=SHORT`
    Then the output should contain:
      """
      repo2: repo2
      """
    And the output should not contain:
      """
      repo3: repo3
      """

  Scenario: Reading default config file 'config/repo.conf
    Given a file named "config/repo.conf" with:
      """
      ---
      repos:
        repo3:
          path: repo3
      """
    When I run `repo list --listing=SHORT`
    Then the output should contain:
      """
      repo3: repo3
      """

  Scenario: Config file is a pattern, read from multiple files
    Given a file named "config/repo1.yml" with:
      """
      ---
      repos:
        repo1:
          path: repo1
      """
    And a file named "config/repo2.yml" with:
      """
      ---
      repos:
        repo2:
          path: repo2
      """
    When I run `repo list --listing=SHORT --config=config/*.yml`
    Then the output should contain:
      """
      repo1: repo1
      repo2: repo2
      """

  Scenario: Config file on command line is a pattern, but doesn't match any files
    When I run `repo path --config=config/*.invalid_pattern`
    Then the exit status should be 1
    And the output should contain:
      """
      config file not found
      """

  Scenario: Config file pattern doesn't match any files
    Given a file named "repo.conf" with:
      """
      ---
      config: config/*.invalid_pattern
      repos:
        repo0:
          path: repo0
      """
    When I run `repo path`
    Then the exit status should be 1
    And the output should contain:
      """
      config file pattern did not match any files
      """

  Scenario: Config file contains a config file pattern, read from mutiple files
    Given a file named "repo.conf" with:
      """
      ---
      config: config/*.yml
      repos:
        repo0:
          path: repo0
      """
    And a file named "config/repo1.yml" with:
      """
      ---
      repos:
        repo1:
          path: repo1
      """
    And a file named "config/repo2.yml" with:
      """
      ---
      repos:
        repo2:
          path: repo2
      """
    When I run `repo list --listing=SHORT`
    Then the output should contain:
      """
      repo0: repo0
      repo1: repo1
      repo2: repo2
      """
