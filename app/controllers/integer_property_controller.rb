class IntegerPropertyController < ApplicationController
  respond_to :html

  # GET /integer_property
  # GET /integer_property.xml
  def index
    @scan_history_polling = IntegerProperty.find_by_property_key('scan_history_polling').property_value
    @nsc_polling = IntegerProperty.find_by_property_key('nsc_polling').property_value
    polling_time_frame = IntegerProperty.find_by_property_key('scan_history_polling_time_frame').property_value
    scan_history_time_frame = ScanHistoryTimeFrame.find_by_id polling_time_frame
    @time_frame = scan_history_time_frame.time_type
  end

  # GET /integer_property/1
  # GET /integer_property/1.xml
  def show
    @general_configuration = IntegerProperty.all
    polling_time_frame = IntegerProperty.find_by_property_key('scan_history_polling_time_frame').property_value
    scan_history_time_frame = ScanHistoryTimeFrame.find_by_id polling_time_frame
    @time_frame = scan_history_time_frame.time_type
  end

  # GET /integer_property/1/edit
  def edit
    @integer_properties = IntegerProperty.all
    polling_time_frame = IntegerProperty.find_by_property_key('scan_history_polling_time_frame').property_value
    @scan_history_time_frame = ScanHistoryTimeFrame.find_by_id polling_time_frame
  end

  # PUT /integer_property/1
  # PUT /integer_property/1.xml
  def update
    @general_configuration = IntegerProperty.find(params[:id])

    params[:general_configuration][:scan_history_polling_time_frame] = params[:scan_history_time_frame][:id]
    respond_to do |format|
      if @general_configuration.update_attributes(params[:general_configuration])
        format.html { redirect_to '/integer_property' }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @general_configuration.errors, :status => :unprocessable_entity }
      end
    end
  end

end
