class IntegerPropertyController < ApplicationController
  respond_to :html

  # GET /integer_property
  # GET /integer_property.xml
  def index
    @integer_properties = IntegerProperty.all
    @scan_history_polling = IntegerProperty.find_by_property_key('scan_history_polling').property_value
    @nsc_polling = IntegerProperty.find_by_property_key('nsc_polling').property_value
    polling_time_frame = IntegerProperty.find_by_property_key('scan_history_polling_time_frame').property_value
    scan_history_time_frame = ScanHistoryTimeFrame.find_by_id polling_time_frame
    @time_frame = scan_history_time_frame.time_type
  end

  # GET /integer_property/1/edit
  def edit
    @scan_history_polling = IntegerProperty.find_by_property_key('scan_history_polling').property_value
    @nsc_polling = IntegerProperty.find_by_property_key('nsc_polling').property_value
    polling_time_frame = IntegerProperty.find_by_property_key('scan_history_polling_time_frame').property_value
    @scan_history_time_frame = ScanHistoryTimeFrame.find_by_id polling_time_frame
  end

  # PUT /integer_property/1
  # PUT /integer_property/1.xml
  def update
    # Just update everything
    scan_history_polling = IntegerProperty.find_by_property_key('scan_history_polling')
    scan_history_polling.property_value = params[:scan_history_polling]
    scan_history_polling.save

    nsc_polling = IntegerProperty.find_by_property_key('nsc_polling')
    updated_nsc_polling = params[:nsc_polling].to_i
    if (updated_nsc_polling != nsc_polling.property_value)
      nsc_polling.property_value = updated_nsc_polling
      nsc_polling.save
    end

    polling_time_frame = IntegerProperty.find_by_property_key('scan_history_polling_time_frame')
    polling_time_frame.property_value = params[:scan_history_time_frame][:id]
    polling_time_frame.save

    redirect_to :integer_property
  end

end
