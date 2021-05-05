# frozen_string_literal: true

module Helpers
  module FileHelpers
    def self.clean_file(filename, *folders)
      return unless filename

      full_path = File.join(*folders, filename)
      File.delete(full_path) if File.exist?(full_path)
    end
  end
end
