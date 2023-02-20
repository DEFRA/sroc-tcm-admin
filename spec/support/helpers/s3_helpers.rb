# frozen_string_literal: true

module Helpers
  module S3Helpers
    def self.any_request
      %r{https://.*\.s3\.#{ENV["BUCKET_AWS_REGION"]}\.amazonaws\.com/.*}
    end

    def self.any_bucket_regex(path = "", file_name = "")
      %r{https://.*\.s3\.#{ENV["BUCKET_AWS_REGION"]}\.amazonaws\.com/#{path}/#{file_name}}
    end

    def self.list_uploads_regex(path = "")
      %r{https://.*\.s3\.#{ENV["BUCKET_AWS_REGION"]}\.amazonaws\.com/\?list-type=2&prefix=#{path}}
    end

    def self.uploads_regex(path = "", file_name = "")
      %r{https://#{ENV["FILE_UPLOAD_BUCKET"]}\.s3\.#{ENV["BUCKET_AWS_REGION"]}\.amazonaws\.com/#{path}/#{file_name}}
    end

    def self.archives_regex(path = "", file_name = "")
      %r{https://#{ENV["ARCHIVE_BUCKET"]}\.s3\.#{ENV["BUCKET_AWS_REGION"]}\.amazonaws\.com/#{path}/#{file_name}}
    end

    def self.list_response(path = "", file_name = "")
      template_response = Helpers::FileHelpers.fixture_content("s3_list_response_template.xml")
      template_response.gsub!("S3_PATH", path).gsub!("S3_FILENAME", file_name)
    end
  end
end
