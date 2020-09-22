# frozen_string_literal: true

require 'net/http'

class BillRunService
  def get_bill_run_id(regime, region, pre_sroc)
    # Check the bill runs table for given attributes and return id if one exists
    bill_run = BillRun.find_by(regime: regime, region: region, pre_sroc: pre_sroc)
    return bill_run.bill_run_id unless bill_run.nil?

    # A bill run isn't in the table so query the API
    bill_run_id_from_api = api_get_bill_run(regime, region, pre_sroc)

    # If an initialised bill run doesn't exist then create one
    bill_run_id_from_api = api_create_bill_run(regime, region) if bill_run_id_from_api.nil?

    # Store the id we now have in the table
    new_bill_run_entry = BillRun.create(bill_run_id: bill_run_id_from_api, region: region, regime: regime, pre_sroc: pre_sroc)

    # Return the id
    new_bill_run_entry.bill_run_id
  end

  private

  def api_get_bill_run(regime, region, pre_sroc)
    # TODO: Correctly handle error responses
    list_bill_runs_call = ChargingModule::ListBillRunsService.call(regime: regime, region: region, status: 'initialised')
    data = list_bill_runs_call.response[:data]
    initialised_pre_sroc_bill_run = data[:billRuns].select { |bill_run| bill_run[:preSroc] == pre_sroc }

    initialised_pre_sroc_bill_run.first[:id] unless initialised_pre_sroc_bill_run.empty?
  end

  def api_create_bill_run(regime, region)
    # TODO: will need to account for pre-sroc=FALSE when sroc is added
    # TODO: Correctly handle error responses
    create_bill_run_call = ChargingModule::CreateBillRunService.call(regime: regime, region: region)

    create_bill_run_call.response[:billRun][:id]
  end
end
