require 'repoman'

module Repoman

  module GenerateHelper

    def validate_options(name, options = {})
      file = options[:file]
      path = options[:path]
      remote = options[:remote]

      unless file && path && remote
        say "reading repo config file..."
        repoman_options = {}
        repoman_options[:config] = options[:config]
        configuration = ::Repoman::Settings.new(FileUtils.pwd, repoman_options).to_hash
        raise "unable to find repo config file" unless configuration[:repo_configuration_filename]
      end

      unless file
        glob = configuration[:repo_configuration_glob]
        puts glob
        config_folder =  File.dirname(glob) if glob
        unless config_folder
          say "repo_configuration_glob key not specified or invalid in repo.conf, please set key or specify '--file=' on the command line"
          exit 1
        end
        file = File.join(File.expand_path(config_folder), "#{name}.yml")
        say file
      end

      unless remote
        defaults = configuration[:defaults] || {}
        remote_dirname = defaults[:remote_dirname]
        unless remote_dirname
          say "[:defaults][:remote_dirname] not found in repo.conf, please set key or specify '--remote=' on the command line"
          exit 1
        end
        remote = "#{File.join(remote_dirname, name + '.git')}"
      end

      path ||= FileUtils.pwd

      # write back to options hash, but it is frozen, so dup a new one
      configuration = options.dup
      configuration[:file] = file
      configuration[:path] = path
      configuration[:remote] = remote

      configuration
    end

    # write a YAML config file for a single repo
    def do_config(name, options = {})
      # set instance vars for generator
      @name = name
      @path = options[:path]
      @remote = options[:remote]

      template_name = "templates/repo.erb"

      file = options[:file]
      FileUtils.rm(file) if options[:force] && File.exist?(file)

      if File.exist?(file)
        say "Skipping #{file} because it already exists. Use --force to overwrite", :red
      else
        say "Creating repoman configuration file"
        template template_name, file
      end
    end

  end

  # @example Generate a repo config
  #
  #   thor repoman:generate:config test_me
  #
  # @example Generate a repo config overriding the CWD
  #
  #   thor repoman:generate:config test_me --path='tmp/aruba/test1'
  #
  # @example Extending the generate class to include initializing and pushing
  #
  #   # encoding: utf-8
  #
  #   require 'repoman/tasks'
  #
  #   module Repoman
  #
  #     class Generate < Thor
  #
  #       # Generate a repo config and 'git init' it from the working folder
  #       #
  #       # @example From the repo working
  #       #
  #       #   cd ~/my_repo_name
  #       #   thor repoman:generate:init my_repo_name
  #       #
  #       desc "init REPO_NAME", "create repo config file and initialize the repo"
  #       def init(name)
  #         configuration = validate_options(name, options)
  #         do_config(name, configuration)
  #
  #         run("git init")
  #         run("git add .")
  #         run("git commit -m 'initial commit'")
  #         exit $?.exitstatus if ($?.exitstatus > 1)
  #
  #         run("git remote add origin #{configuration[:remote]}")
  #         run("git config branch.master.remote origin")
  #         run("git config branch.master.merge refs/heads/master")
  #         exit $?.exitstatus if ($?.exitstatus > 1)
  #
  #         run("git clone --bare #{shell_quote(configuration[:path])} #{configuration[:remote]}")
  #         exit $?.exitstatus if ($?.exitstatus > 1)
  #
  #         run("git push origin master:refs/heads/master")
  #         exit $?.exitstatus if ($?.exitstatus > 1)
  #
  #         say "init done on '#{name}'", :green
  #       end
  #     end
  #   end
  #
  class Generate < Thor
    include Thor::Actions
    include Repoman::ThorHelper
    include Repoman::GenerateHelper

    class_option :force, :type => :boolean, :desc => "Force overwrite of existing config file"
    class_option :config, :type => :string, :desc => "Repoman config file"
    class_option :path, :type => :string, :aliases => "-p", :desc => "Full path to working folder"
    class_option :file, :type => :string, :desc => "Repo config file name", :banner => "filename"
    class_option :remote, :type => :string, :aliases => "-r", :desc => "Repo remote origin, i.e.  'git@host.git' or '//smb/path", :banner => "//smb/remote/path"

    desc "config REPO_NAME", "generate repoman config file for a single repo"
    def config(name)
      configuration = validate_options(name, options)
      do_config(name, configuration)
    end

    private

    # where to start looking, required by the template method
    def self.source_root
      File.dirname(__FILE__)
    end

  end
end
