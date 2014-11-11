require_relative "../lib/core_ext"
require_relative "storm/error"
require_relative "storm/base"
require_relative "storm/v0"

module Storm
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  # VALID_PASS_REGEX = /\A.*(?=.{10,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=]).*\z/
  VALID_PASS_REGEX = /\A.*(?=.{6,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*\z/
  SURVEY_EXP_DAYS = 14
end
