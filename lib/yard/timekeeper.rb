# frozen_string_literal: true

require "version_gem"
require_relative "timekeeper/version"

Yard::Timekeeper::Version.class_eval do
  extend VersionGem::Basic
end
module Yard
  module Timekeeper
    class Error < StandardError; end
    # Your code goes here...
  end
end
