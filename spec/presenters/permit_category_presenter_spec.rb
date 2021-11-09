# frozen_string_literal: true

require "rails_helper"

RSpec.describe PermitCategoryPresenter do
  let(:subject) { PermitCategoryPresenter.new(permit_category) }
  let(:regime) { create(:regime) }
  let(:user) { create(:user_with_regime, regime: regime) }

  before(:each) do
    # This is a common call in a number of places in the code required for the auditing solution implemented. It expects
    # the current user to be set so it can capture who performed the action. In this case when a new transaction file
    # is created who created it is audited
    Thread.current[:current_user] = user
  end

  describe "#as_json" do
    let(:permit_category) { create(:permit_category, regime: regime) }

    it "returns the correct value" do
      expect(subject.as_json).to eq(
        {
          code: "2.3.4",
          description: "Sewage 50,000 - 150,000 m3/day",
          edit_link: "/regimes/cfd/permit_categories/#{permit_category.id}/edit",
          id: permit_category.id,
          status: "active",
          valid_from: "1819",
          valid_to: nil
        }
      )
    end
  end

  describe ".wrap" do
    let(:permit_categories) do
      [
        build(:permit_category, regime: regime, code: "1.2.3"),
        build(:permit_category, regime: regime, code: "3.2.1")
      ]
    end

    it "returns a collection containing a PermitCategoryPresenter for each PermitCategory" do
      result = PermitCategoryPresenter.wrap(permit_categories)

      expect(result.length).to eq(2)
      expect(result[0]).to be_a(PermitCategoryPresenter)
      expect(result[0].code).to eq(permit_categories[0].code)
    end
  end
end
