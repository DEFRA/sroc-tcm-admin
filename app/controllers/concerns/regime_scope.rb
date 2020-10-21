# frozen_string_literal: true

module RegimeScope
  extend ActiveSupport::Concern

  # :nocov:
  def presenter
    name = "#{@regime.slug}_transaction_detail_presenter".camelize
    str_to_class(name) || TransactionDetailPresenter
  end

  def str_to_class(name)
    
      name.constantize
    rescue NameError => e
      nil
    
  end

  def set_regime
    last_id = cookies[:regime_id]
    r_id = params.fetch(:regime_id, nil)

    if r_id
      @regime = current_user.set_selected_regime(r_id)
      redirect_to root_path unless @regime.to_param == r_id
    else
      @regime = current_user.selected_regime
    end
    cookies[:regime_id] = @regime.to_param unless @regime.nil?
  end
  # :nocov:
end
