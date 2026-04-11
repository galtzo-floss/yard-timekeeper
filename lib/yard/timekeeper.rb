# frozen_string_literal: true

require "open3"
require "version_gem"
require_relative "timekeeper/version"

Yard::Timekeeper::Version.class_eval do
  extend VersionGem::Basic
end
module Yard
  module Timekeeper
    class Error < StandardError; end

    TIMESTAMP_DIFF_LINE_RE = /\A[+-]\s{2}Generated on .+ by\s*\z/
    DIFF_METADATA_PREFIXES = [
      "diff --git ",
      "index ",
      "--- ",
      "+++ ",
      "@@ ",
    ].freeze

    class << self
      def postprocess_html_docs
        return unless enabled?

        docs_dir = File.join(Dir.pwd, "docs")
        return unless Dir.exist?(docs_dir)

        root = git_root
        return unless root

        changed_docs_files(root).each do |relative_path|
          next unless relative_path.end_with?(".html")
          next unless timestamp_only_diff?(git_diff(relative_path, root))

          restore_file(relative_path, root)
        end
      rescue StandardError => e
        warn("Yard::Timekeeper.postprocess_html_docs failed: #{e.class}: #{e.message}")
      end

      def enabled?
        !ENV.fetch("YARD_TIMEKEEPER_DISABLE", "false").casecmp?("true")
      end

      def git_root
        stdout, status = Open3.capture2("git", "rev-parse", "--show-toplevel", chdir: Dir.pwd)
        return unless status.success?

        stdout.strip
      rescue Errno::ENOENT
        nil
      end

      def changed_docs_files(root)
        stdout, status = Open3.capture2("git", "diff", "--name-only", "--relative", "--", "docs", chdir: root)
        return [] unless status.success?

        stdout.lines.map(&:strip).reject(&:empty?)
      rescue Errno::ENOENT
        []
      end

      def git_diff(path, root)
        stdout, _status = Open3.capture2(
          "git",
          "diff",
          "--no-ext-diff",
          "--no-color",
          "--unified=0",
          "--",
          path,
          chdir: root,
        )
        stdout
      end

      def timestamp_only_diff?(diff_text)
        return false if diff_text.to_s.strip.empty?

        change_lines = []

        diff_text.each_line do |line|
          next if DIFF_METADATA_PREFIXES.any? { |prefix| line.start_with?(prefix) }
          next if line.strip.empty?

          return false unless line.match?(TIMESTAMP_DIFF_LINE_RE)

          change_lines << line
        end

        change_lines.size == 2 &&
          change_lines.one? { |line| line.start_with?("-") } &&
          change_lines.one? { |line| line.start_with?("+") }
      end

      def restore_file(path, root)
        _stdout, _stderr, status = Open3.capture3("git", "checkout", "--", path, chdir: root)
        status.success?
      rescue Errno::ENOENT
        false
      end
    end
  end
end

unless ENV["YARD_TIMEKEEPER_SKIP_AT_EXIT"] == "1"
  at_exit do
    Yard::Timekeeper.postprocess_html_docs
  end
end
