class ScanInfo

  attr_accessor :status, :scan_id, :host

  def initialize scan_id
    @scan_id = scan_id
    @scan_data = nil
  end


  def has_scan_data?
    if @scan_data
      true
    else
      false
    end
  end

  def add_scan_data scan_data
    @scan_data = scan_data
  end

end