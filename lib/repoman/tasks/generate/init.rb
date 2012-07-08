require 'fileutils'
require 'repoman/views/view_helper'

module Repoman
  class Generate < Thor
    namespace :generate
    include Thor::Actions
    include Repoman::ThorHelper
    include ::Repoman::ViewHelper

    desc "init PATH", "create the initial configuration file and folder structure"
    def init(path)
      logger.debug "init task initial configuration: #{configuration.inspect}"

      # create instance var so that it can be referenced in templates
      @path = path ? File.expand_path(path) : FileUtils.pwd

      source = path_to(:repoman, File.join('lib', 'repoman', 'tasks', 'generate', 'templates', 'config', 'repo.conf.tt'))
      destination = File.join(@path, 'repo.conf')

      say_status :init, "creating initial config file at '#{destination}'"
      template(source, destination)

      source = path_to(:repoman, File.join('lib', 'repoman', 'tasks', 'generate', 'templates', 'init', '.'))
      destination = @path

      say_status :init, "creating initial file structure in '#{destination}'"
      directory(source, destination)

      return 0
    end

    private

    # where to start looking, required by the template method
    def self.source_root
      File.dirname(__FILE__)
    end


  end
end
