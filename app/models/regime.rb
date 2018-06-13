class Regime < ApplicationRecord
  has_many :sequence_counters, inverse_of: :regime, dependent: :destroy
  has_many :transaction_headers, inverse_of: :regime, dependent: :destroy
  has_many :transaction_details, through: :transaction_headers
  has_many :permits, inverse_of: :regime, dependent: :destroy
  has_many :permit_categories, inverse_of: :regime, dependent: :destroy
  has_many :transaction_files, inverse_of: :regime, dependent: :destroy
  has_many :annual_billing_data_files, inverse_of: :regime, dependent: :destroy
  has_many :exclusion_reasons, inverse_of: :regime, dependent: :destroy

  has_many :regime_users, inverse_of: :regime, dependent: :destroy
  has_many :users, through: :regime_users

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true
  before_save :generate_slug

  def to_param
    slug
  end

  def waste_or_installations?
    waste? || installations?
  end

  def waste?
    slug == 'wml'
  end

  def installations?
    slug == 'pas'
  end

  def water_quality?
    slug == 'cfd'
  end

  def retrospective_date?(end_date)
    end_date < retrospective_cut_off_date
  end

  def regions
    if water_quality?
      %w[ A B E N S T Y]
    elsif installations?
      %w[ A B E N S Y]
    elsif waste?
      %w[ A B E N S T U Y]
    else
      raise "Unknown regime #{slug}"
    end
  end

private
  def generate_slug
    self.slug = name.parameterize.downcase
  end
end
