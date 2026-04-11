# frozen_string_literal: true

require "fileutils"
require "tmpdir"

RSpec.describe Yard::Timekeeper do
  it "has a version number" do
    expect(Yard::Timekeeper::VERSION).not_to be_nil
  end

  describe "::timestamp_only_diff?" do
    it "matches a diff containing only the generated-on footer timestamp change" do
      diff = <<~DIFF
        diff --git a/docs/index.html b/docs/index.html
        index abc123..def456 100644
        --- a/docs/index.html
        +++ b/docs/index.html
        @@ -1166 +1166 @@
        -  Generated on Sat Apr 11 01:22:58 2026 by
        +  Generated on Sat Apr 11 01:23:17 2026 by
      DIFF

      expect(described_class.timestamp_only_diff?(diff)).to be(true)
    end

    it "rejects diffs with any non-timestamp content changes" do
      diff = <<~DIFF
        diff --git a/docs/index.html b/docs/index.html
        index abc123..def456 100644
        --- a/docs/index.html
        +++ b/docs/index.html
        @@ -4 +4 @@
        -<title>Old Title</title>
        +<title>New Title</title>
        @@ -1166 +1166 @@
        -  Generated on Sat Apr 11 01:22:58 2026 by
        +  Generated on Sat Apr 11 01:23:17 2026 by
      DIFF

      expect(described_class.timestamp_only_diff?(diff)).to be(false)
    end
  end

  describe "::postprocess_html_docs" do
    it "returns early when docs directory is absent" do
      Dir.mktmpdir do |dir|
        allow(Dir).to receive(:pwd).and_return(dir)

        expect { described_class.postprocess_html_docs }.not_to raise_error
      end
    end

    it "restores only html files with timestamp-only diffs" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "docs"))
        allow(Dir).to receive(:pwd).and_return(dir)

        allow(described_class).to receive_messages(
          git_root: dir,
          restore_file: true,
        )
        allow(described_class).to receive(:changed_docs_files).with(dir).and_return([
          "docs/index.html",
          "docs/file.README.html",
          "docs/style.css",
        ])
        allow(described_class).to receive(:git_diff).with("docs/index.html", dir).and_return(<<~DIFF)
          @@ -1166 +1166 @@
          -  Generated on Sat Apr 11 01:22:58 2026 by
          +  Generated on Sat Apr 11 01:23:17 2026 by
        DIFF
        allow(described_class).to receive(:git_diff).with("docs/file.README.html", dir).and_return(<<~DIFF)
          @@ -10 +10 @@
          -<p>old</p>
          +<p>new</p>
        DIFF

        described_class.postprocess_html_docs

        expect(described_class).to have_received(:restore_file).with("docs/index.html", dir)
        expect(described_class).not_to have_received(:restore_file).with("docs/file.README.html", dir)
        expect(described_class).not_to have_received(:restore_file).with("docs/style.css", dir)
      end
    end

    it "rescues and warns on unexpected errors" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "docs"))
        allow(Dir).to receive(:pwd).and_return(dir)
        allow(described_class).to receive(:git_root).and_raise(StandardError, "boom")

        expect { described_class.postprocess_html_docs }
          .to output("Yard::Timekeeper.postprocess_html_docs failed: StandardError: boom\n").to_stderr
      end
    end
  end

  describe "::restore_file" do
    it "uses git checkout to restore the tracked file from HEAD" do
      status = instance_double(Process::Status, success?: true)
      allow(Open3).to receive(:capture3).and_return(["", "", status])

      expect(described_class.restore_file("docs/index.html", "/tmp/project")).to be(true)
      expect(Open3).to have_received(:capture3).with("git", "checkout", "--", "docs/index.html", chdir: "/tmp/project")
    end
  end
end
