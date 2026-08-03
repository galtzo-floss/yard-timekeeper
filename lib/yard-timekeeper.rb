# frozen_string_literal: true

# YARD plugin loader for `--plugin timekeeper`.
# YARD tries requiring several patterns; providing `yard-timekeeper` ensures
# it can be loaded regardless of whether YARD attempts `yard-timekeeper`
# or `yard/timekeeper`.
require_relative "yard/timekeeper"
