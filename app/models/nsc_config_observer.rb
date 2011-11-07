class NscConfigObserver < ActiveRecord::Observer

  def after_save nsc_config
    if nsc_config.is_active?
      # Add to the NSC Conn manager
    end
  end
end