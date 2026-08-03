# frozen_string_literal: true

require "open3"

module Yard
  module Timekeeper
    class Error < StandardError; end
    RAKE_INTEGRATIONS = {}
    RAKE_INTEGRATIONS_MUTEX = Mutex.new

    TITLE_GENERATOR_DIFF_LINE_RE = /\A[+-].*Documentation by YARD \d+(?:\.\d+)+(?:[.\w-][.\w-]*)?\s*\z/
    TIMESTAMP_DIFF_LINE_RE = /\A[+-]\s{2}Generated on .+ by\s*\z/
    FOOTER_GENERATOR_VERSION_DIFF_LINE_RE = /
      \A[+-]\s{2}
      \d+(?:\.\d+)+(?:[.\w-][.\w-]*)?
      \s\(ruby-[^)]+\)\.\s*
      \z
    /x
    TITLE_GENERATOR_LINE_RE = /Documentation by YARD \d+(?:\.\d+)+(?:[.\w-][.\w-]*)?/
    TIMESTAMP_LINE_RE = /\A\s{2}Generated on .+ by\s*\z/
    FOOTER_GENERATOR_VERSION_LINE_RE = /
      \A\s{2}
      \d+(?:\.\d+)+(?:[.\w-][.\w-]*)?
      \s\(ruby-[^)]+\)\.\s*
      \z
    /x
    DIFF_METADATA_PREFIXES = [
      "diff --git ",
      "index ",
      "--- ",
      "+++ ",
      "@@ "
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
          diff = git_diff(relative_path, root)
          if timestamp_only_diff?(diff)
            restore_file(relative_path, root)
          else
            normalize_generated_metadata(relative_path, root)
          end
        end
      rescue => e
        warn("Yard::Timekeeper.postprocess_html_docs failed: #{e.class}: #{e.message}")
      end

      def run_at_exit
        postprocess_html_docs
      end

      def install_rake_tasks!(yard_task_name = :yard)
        return false unless defined?(::Rake::Task) && ::Rake::Task.task_defined?(yard_task_name)

        RAKE_INTEGRATIONS_MUTEX.synchronize do
          key = yard_task_name.to_s
          unless RAKE_INTEGRATIONS[key]
            ::Rake::Task[yard_task_name].enhance { ::Yard::Timekeeper.postprocess_html_docs }
            RAKE_INTEGRATIONS[key] = true
          end
        end

        true
      end

      def __reset_rake_integrations__
        RAKE_INTEGRATIONS_MUTEX.synchronize { RAKE_INTEGRATIONS.clear }
        nil
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
          chdir: root
        )
        stdout
      end

      def timestamp_only_diff?(diff_text)
        return false if diff_text.to_s.strip.empty?

        change_lines = []

        diff_text.each_line do |line|
          next if DIFF_METADATA_PREFIXES.any? { |prefix| line.start_with?(prefix) }
          next if line.strip.empty?

          return false unless footer_churn_line?(line)

          change_lines << line
        end

        balanced_footer_churn?(change_lines)
      end

      def footer_churn_line?(line)
        line.match?(TITLE_GENERATOR_DIFF_LINE_RE) ||
          line.match?(TIMESTAMP_DIFF_LINE_RE) ||
          line.match?(FOOTER_GENERATOR_VERSION_DIFF_LINE_RE)
      end

      def balanced_footer_churn?(change_lines)
        removed_lines = change_lines.select { |line| line.start_with?("-") }
        added_lines = change_lines.select { |line| line.start_with?("+") }

        removed_lines.size == added_lines.size &&
          removed_lines.size.between?(1, 2) &&
          removed_lines.map { |line| footer_churn_kind(line) }.sort ==
            added_lines.map { |line| footer_churn_kind(line) }.sort
      end

      def footer_churn_kind(line)
        return :title_generator if line.match?(TITLE_GENERATOR_DIFF_LINE_RE)
        return :timestamp if line.match?(TIMESTAMP_DIFF_LINE_RE)
        return :footer_generator_version if line.match?(FOOTER_GENERATOR_VERSION_DIFF_LINE_RE)

        :unknown
      end

      def normalize_generated_metadata(path, root)
        original = tracked_file_content(path, root)
        return false unless original

        absolute_path = File.join(root, path)
        return false unless File.file?(absolute_path)

        replacement_lines = generated_metadata_lines(original)
        return false if replacement_lines.empty?

        current = File.read(absolute_path)
        changed = false
        normalized_lines = current.lines.map do |line|
          kind = generated_metadata_kind(line)
          replacement = replacement_lines[kind]
          normalized_line = replacement ? normalize_generated_metadata_line(line, kind, replacement) : line
          if replacement && line != normalized_line
            changed = true
            normalized_line
          else
            line
          end
        end

        return false unless changed

        File.write(absolute_path, normalized_lines.join)
        true
      end

      def tracked_file_content(path, root)
        stdout, status = Open3.capture2("git", "show", "HEAD:#{path}", chdir: root)
        return unless status.success?

        stdout
      rescue Errno::ENOENT
        nil
      end

      def generated_metadata_lines(content)
        content.lines.each_with_object({}) do |line, replacements|
          kind = generated_metadata_kind(line)
          replacements[kind] ||= generated_metadata_value(line, kind) if kind
        end
      end

      def generated_metadata_value(line, kind)
        case kind
        when :title_generator
          line[TITLE_GENERATOR_LINE_RE]
        else
          line
        end
      end

      def normalize_generated_metadata_line(line, kind, replacement)
        case kind
        when :title_generator
          line.sub(TITLE_GENERATOR_LINE_RE, replacement.to_s)
        else
          replacement
        end
      end

      def generated_metadata_kind(line)
        stripped_line = line.strip
        return :title_generator if stripped_line.match?(TITLE_GENERATOR_LINE_RE)
        return :timestamp if line.match?(TIMESTAMP_LINE_RE)
        return :footer_generator_version if line.match?(FOOTER_GENERATOR_VERSION_LINE_RE)

        nil
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
# Rake integration is explicit. Call Yard::Timekeeper.install_rake_tasks! from
# your Rakefile after defining the :yard task so postprocess only runs for
# documentation builds, never for unrelated processes that happen to load YARD.
