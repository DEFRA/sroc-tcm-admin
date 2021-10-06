# frozen_string_literal: true

module Exceptions
  class FileNotFoundError < StandardError; end
  class TransactionFileError < StandardError; end
  class PermissionError < StandardError; end
  class RulesServiceError < StandardError; end
end
