class GeneralConfigurationsController < ApplicationController
  # GET /general_configurations
  # GET /general_configurations.xml
  def index
    @general_configurations = GeneralConfiguration.all

    unless @general_configurations.empty?
      #There should only be one
      scan_history_time_frame = ScanHistoryTimeFrame.find_by_id @general_configurations[0].scan_history_polling_time_frame
      @time_frame = scan_history_time_frame.time_type
    end

    respond_to do |format|
      format.html # index.html.haml.old
      format.xml { render :xml => @general_configurations }
    end
  end

  # GET /general_configurations/1
  # GET /general_configurations/1.xml
  def show
    @general_configurations = GeneralConfiguration.all

    unless @general_configurations.empty?
      #There should only be one
      scan_history_time_frame = ScanHistoryTimeFrame.find_by_id @general_configurations[0].scan_history_polling_time_frame
      @time_frame = scan_history_time_frame.time_type
    end


    respond_to do |format|
      format.html # index.html.haml.old
      format.xml { render :xml => @general_configurations }
    end
  end

  # GET /general_configurations/new
  # GET /general_configurations/new.xml
  def new
    @general_configuration = GeneralConfiguration.new

    respond_to do |format|
      format.html # new.html.haml
      format.xml { render :xml => @general_configuration }
    end
  end

  # GET /general_configurations/1/edit
  def edit
    @general_configuration = GeneralConfiguration.find(params[:id])
    id = @general_configuration.scan_history_polling_time_frame
    @scan_history_time_frame = ScanHistoryTimeFrame.find_by_id id
  end

  # POST /general_configurations
  # POST /general_configurations.xml
  def create
    @general_configuration = GeneralConfiguration.new(params[:general_configuration])

    respond_to do |format|
      if @general_configuration.save
        format.html { redirect_to(@general_configuration, :notice => 'General configuration was successfully created.') }
        format.xml { render :xml => @general_configuration, :status => :created, :location => @general_configuration }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @general_configuration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /general_configurations/1
  # PUT /general_configurations/1.xml
  def update
    @general_configuration = GeneralConfiguration.find(params[:id])

    params[:general_configuration][:scan_history_polling_time_frame] = params[:scan_history_time_frame][:id]
    respond_to do |format|
      if @general_configuration.update_attributes(params[:general_configuration])
        format.html { redirect_to '/general_configurations' }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @general_configuration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /general_configurations/1
  # DELETE /general_configurations/1.xml
  def destroy
    @general_configuration = GeneralConfiguration.find(params[:id])
    @general_configuration.destroy

    respond_to do |format|
      format.html { redirect_to(general_configurations_url) }
      format.xml { head :ok }
    end
  end
end
