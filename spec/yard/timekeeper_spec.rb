# frozen_string_literal: true

require "fileutils"
require "rake"
require "tmpdir"

RSpec.describe Yard::Timekeeper do
  it "has a version number" do
    expect(Yard::Timekeeper::VERSION).not_to be_nil
  end

  describe "::enabled?" do
    it "returns true by default" do
      hide_env("YARD_TIMEKEEPER_DISABLE")

      expect(described_class.enabled?).to be(true)
    end

    it "returns false when explicitly disabled" do
      stub_env("YARD_TIMEKEEPER_DISABLE" => "true")

      expect(described_class.enabled?).to be(false)
    end
  end

  describe "::git_root" do
    it "returns the stripped git root when git succeeds" do
      status = instance_double(Process::Status, success?: true)
      allow(Open3).to receive(:capture2)
        .with("git", "rev-parse", "--show-toplevel", chdir: Dir.pwd)
        .and_return(["/tmp/project\n", status])

      expect(described_class.git_root).to eq("/tmp/project")
    end

    it "returns nil when git rev-parse fails" do
      status = instance_double(Process::Status, success?: false)
      allow(Open3).to receive(:capture2).and_return(["", status])

      expect(described_class.git_root).to be_nil
    end

    it "returns nil when git is unavailable" do
      allow(Open3).to receive(:capture2).and_raise(Errno::ENOENT)

      expect(described_class.git_root).to be_nil
    end
  end

  describe "::changed_docs_files" do
    it "returns changed docs paths when git diff succeeds" do
      status = instance_double(Process::Status, success?: true)
      allow(Open3).to receive(:capture2)
        .with("git", "diff", "--name-only", "--relative", "--", "docs", chdir: "/tmp/project")
        .and_return(["docs/index.html\n\ndocs/classes/Foo.html\n", status])

      expect(described_class.changed_docs_files("/tmp/project")).to eq(["docs/index.html", "docs/classes/Foo.html"])
    end

    it "returns an empty array when git diff fails" do
      status = instance_double(Process::Status, success?: false)
      allow(Open3).to receive(:capture2).and_return(["", status])

      expect(described_class.changed_docs_files("/tmp/project")).to eq([])
    end

    it "returns an empty array when git is unavailable" do
      allow(Open3).to receive(:capture2).and_raise(Errno::ENOENT)

      expect(described_class.changed_docs_files("/tmp/project")).to eq([])
    end
  end

  describe "::git_diff" do
    it "returns stdout from git diff" do
      status = instance_double(Process::Status, success?: true)
      allow(Open3).to receive(:capture2)
        .with(
          "git",
          "diff",
          "--no-ext-diff",
          "--no-color",
          "--unified=0",
          "--",
          "docs/index.html",
          chdir: "/tmp/project",
        ).and_return(["diff output", status])

      expect(described_class.git_diff("docs/index.html", "/tmp/project")).to eq("diff output")
    end
  end

  describe "::timestamp_only_diff?" do
    it "rejects empty diffs" do
      expect(described_class.timestamp_only_diff?(" \n")).to be(false)
    end

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

    it "ignores diff metadata and blank lines while checking timestamp-only changes" do
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
    it "returns early when timekeeper is disabled" do
      Dir.mktmpdir do |dir|
        stub_env("YARD_TIMEKEEPER_DISABLE" => "true")
        allow(Dir).to receive(:pwd).and_return(dir)
        allow(described_class).to receive(:git_root)

        described_class.postprocess_html_docs

        expect(described_class).not_to have_received(:git_root)
      end
    end

    it "returns early when docs directory is absent" do
      Dir.mktmpdir do |dir|
        allow(Dir).to receive(:pwd).and_return(dir)

        expect { described_class.postprocess_html_docs }.not_to raise_error
      end
    end

    it "returns early when git root cannot be determined" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "docs"))
        allow(Dir).to receive(:pwd).and_return(dir)
        allow(described_class).to receive(:git_root).and_return(nil)
        allow(described_class).to receive(:changed_docs_files)

        described_class.postprocess_html_docs

        expect(described_class).not_to have_received(:changed_docs_files)
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

    it "returns false when git checkout fails" do
      status = instance_double(Process::Status, success?: false)
      allow(Open3).to receive(:capture3).and_return(["", "", status])

      expect(described_class.restore_file("docs/index.html", "/tmp/project")).to be(false)
    end

    it "returns false when git is unavailable" do
      allow(Open3).to receive(:capture3).and_raise(Errno::ENOENT)

      expect(described_class.restore_file("docs/index.html", "/tmp/project")).to be(false)
    end
  end

  describe "::run_at_exit" do
    it "delegates to postprocess_html_docs" do
      allow(described_class).to receive(:postprocess_html_docs)

      described_class.run_at_exit

      expect(described_class).to have_received(:postprocess_html_docs)
    end
  end

  describe "::install_rake_tasks!" do
    before do
      Rake::Task.clear
      described_class.__reset_rake_integrations__
      Rake::Task.define_task(:yard)
    end

    it "adds a postprocess action to the yard task" do
      allow(described_class).to receive(:postprocess_html_docs)

      expect(described_class.install_rake_tasks!(:yard)).to be(true)
      Rake::Task[:yard].invoke

      expect(described_class).to have_received(:postprocess_html_docs).once
    end

    it "returns false when the task does not exist" do
      expect(described_class.install_rake_tasks!(:missing)).to be(false)
    end
  end
end
