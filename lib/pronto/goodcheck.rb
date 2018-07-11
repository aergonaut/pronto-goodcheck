require "pronto"
require "pronto/goodcheck/version"
require "goodcheck"
require "pathname"

module Pronto
  class Goodcheck < Runner
    def run
      files = ruby_patches.map(&:new_file_full_path)
      reporter = Goodcheck::Reporters::JSON.new(stdout: $stdout, stderr: $stderr)
      runner = Goodcheck::Commands::Check(
        config_path: Pathname("goodcheck.yml"),
        rules: [],
        targets: files,
        reporter: reporter,
        stderr: $stderr
      )
      runner.run
    end

    def messages_for(issues)
      issues.map do |issue|
        patch = patch_for_issue(issue)
        next if patch.nil?

        line = patch.added_lines.find do |added_line|
          issue.location.start_line == added_line.new_lineno
        end

        new_message(line, issue) if line
      end
    end

    def patch_for_issue(issue)
      ruby_patches.find do |patch|
        patch.new_file_full_path.to_s == issue.path
      end
    end

    def new_message(line, issue)
      path = issue.path
      message = issue.rule.message
      if issue.rule.justifications
        message << "\n\nJustifications\n\n#{issue.rule.justifications}"
      end

      Message.new(path, line, :info, message, nil, self.class)
    end
  end
end
