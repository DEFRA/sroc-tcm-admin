# frozen_string_literal: true

module Helpers
  module FileHelpers
    def self.fixture_path(fixture_filename, fixture_path = "")
      File.join(fixtures_path(fixture_path), fixture_filename)
    end

    def self.fixtures_path(path = "")
      Rails.root.join("spec", "fixtures", path)
    end

    def self.clean_up(filename, *folders)
      return unless filename

      full_path = File.join(*folders, filename)
      File.delete(full_path) if File.exist?(full_path)
    end

    def self.fixture_content(fixture_filename, fixture_path = "")
      fixture = File.open(fixture_path(fixture_filename, fixture_path))

      fixture.read
    end
  end
end
