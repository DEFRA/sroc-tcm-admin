# frozen_string_literal: true

class AnnualBillingDataImportService < ServiceObject
  def initialize(params = {})
    super()

    @upload = params.fetch(:upload)
    @user = params.fetch(:user)
  end

  def call
    @result = false
    file = Tempfile.new

    begin
      # update upload record status
      @upload.state.process!

      regime = @upload.regime
      GetAnnualBillingDataFile.call(remote_path: @upload.filename,
                                    local_path: file.path)

      file.rewind

      data_service = AnnualBillingDataFileService.new(regime, @user)

      data_service.import(@upload, file.path)

      # update upload record status
      @upload.state.complete!

      @result = true
    rescue StandardError => e
      # update upload record status
      upload.state.error!

      TcmLogger.notify(e)
    ensure
      file.close
      file.unlink

      puts("Finished annual billing data import")
    end

    self
  end
end
