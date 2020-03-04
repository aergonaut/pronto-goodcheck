require "pronto"
require "pronto/goodcheck/version"
require "goodcheck"
require "pathname"
require "json"

module Pronto
  class GoodcheckRunner < Runner
    def run
      files = patches_with_changes
        .map { |patch| project_relative_path(patch) }
      stdout = StringIO.new
      stderr = StringIO.new
      reporter = ::Goodcheck::Reporters::JSON.new(
        stdout: stdout,
        stderr: stderr,
      )
      runner = ::Goodcheck::Commands::Check.new(
        config_path: Pathname("goodcheck.yml"),
        rules: [],
        targets: files,
        reporter: reporter,
        stderr: stderr,
        home_path: goodcheck_home_path,
        force_download: false,
      )
      runner.run
      analysis = JSON.load(stdout.string)
      messages_for(Array(analysis))
    end

    def patches_with_changes
      return [] unless @patches

      @patches_with_changes ||= @patches.select { |patch| patch.additions > 0 }
    end

    def messages_for(issues)
      issues.map do |issue|
        patch = patch_for_issue(issue)
        next if patch.nil?

        line = patch.added_lines.find do |added_line|
          issue["location"].nil? || issue["location"]["start_line"] == added_line.new_lineno
        end

        new_message(line, issue) if line
      end
    end

    def patch_for_issue(issue)
      patches_with_changes.find do |patch|
        patch.delta.new_file[:path].to_s == issue["path"]
      end
    end

    def new_message(line, issue)
      path = issue["path"]
      message = "#{issue["message"]}"
      if issue["justifications"].any?
        justifications = ""
        issue["justifications"].each do |justification|
          justifications << "\n* #{justification}"
        end
        message << "\n\nJustifications:\n#{justifications}"
      end

      Message.new(path, line, :info, message, nil, self.class)
    end

    def goodcheck_home_path
      if (path = ENV["GOODCHECK_HOME"])
        Pathname(path)
      else
        Pathname(Dir.home) + ".goodcheck"
      end
    end
    
    def project_relative_path(patch)
      Pathname(patch.delta.new_file[:path])
    end
  end
end
