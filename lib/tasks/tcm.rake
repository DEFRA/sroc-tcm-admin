namespace :tcm do
  desc 'Delete all transaction records from the database'
  task :cleardown => :environment do
    TransactionHeader.destroy_all
  end

  desc 'Generate suggested categories'
  task :dev_populate_categories => :environment do
    levels = [:green, :amber, :red]
    stages = %w[ stage1 stage2 stage3 stage4 ]
    logics = %w[ logic1 logic2 logic3 logic4 ]
    # for audit
    Thread.current[:current_user] = User.system_account

    Regime.all.each do |r|
      permits = PermitStorageService.new(r).all_for_financial_year('1819')
      r.transaction_details.unbilled.where(tcm_financial_year: '1819').each do |t|
        if t.suggested_category.nil?
          level = levels.sample
          stage = stages.sample
          logic = logics.sample
          category = permits.sample.code
          historic = r.transaction_details.historic.sample
          t.transaction do
            t.create_suggested_category!(confidence_level: level,
                                         suggestion_stage: stage,
                                         logic: logic,
                                         category: category,
                                         matched_transaction: historic)
            t.category = category
            t.save!
          end
        end
      end
    end
  end
end
