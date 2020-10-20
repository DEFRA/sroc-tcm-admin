# frozen_string_literal: true

require 'test_helper'

class RegimeTest < ActiveSupport::TestCase
  def setup
    @regime = regimes(:cfd)
  end

  def test_valid_regime
    assert @regime.valid?, "Unexpected errors present #{@regime.errors.inspect}"
  end

  def test_invalid_without_name
    @regime.name = nil
    assert @regime.invalid?
    assert_not_nil @regime.errors[:name]
  end

  def test_invalid_without_title
    @regime.title = nil
    assert @regime.invalid?
    assert_not_nil @regime.errors[:title]
  end

  def test_slug_generated_on_create
    regime = Regime.create!(name: 'ABC', title: 'Test Regime')
    assert_equal 'abc', regime.slug
  end

  def test_slug_regenerated_on_save
    @regime.name = 'XyZ'
    @regime.save!
    assert_equal 'xyz', @regime.slug
  end

  def test_to_param_returns_slug
    assert_equal @regime.slug, @regime.to_param
  end

  def test_waste_regime_returns_true_for_wml
    assert regimes(:wml).waste?
  end

  def test_installations_regime_returns_true_for_pas
    assert regimes(:pas).installations?
  end

  def test_water_quality_regime_returns_true_for_cfd
    assert regimes(:cfd).water_quality?
  end

  def test_waste_or_installations_returns_true_for_wml_and_pas_regimes
    assert regimes(:wml).waste_or_installations?
    assert regimes(:pas).waste_or_installations?
    assert_not regimes(:cfd).waste_or_installations?
  end
end
