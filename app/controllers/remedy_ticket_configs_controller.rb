class RemedyTicketConfigsController < ApplicationController
  # GET /remedy_ticket_configs
  # GET /remedy_ticket_configs.xml
  def index
    @remedy_ticket_configs = RemedyTicketConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @remedy_ticket_configs }
    end
  end

  # GET /remedy_ticket_configs/1
  # GET /remedy_ticket_configs/1.xml
  def show
    @remedy_ticket_config = RemedyTicketConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @remedy_ticket_config }
    end
  end

  # GET /remedy_ticket_configs/new
  # GET /remedy_ticket_configs/new.xml
  def new
    @remedy_ticket_config = RemedyTicketConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @remedy_ticket_config }
    end
  end

  # GET /remedy_ticket_configs/1/edit
  def edit
    @remedy_ticket_config = RemedyTicketConfig.find(params[:id])
  end

  # POST /remedy_ticket_configs
  # POST /remedy_ticket_configs.xml
  def create
    @remedy_ticket_config = RemedyTicketConfig.new(params[:remedy_ticket_config])

    respond_to do |format|
      if @remedy_ticket_config.save
        format.html { redirect_to(@remedy_ticket_config, :notice => 'Remedy ticket config was successfully created.') }
        format.xml  { render :xml => @remedy_ticket_config, :status => :created, :location => @remedy_ticket_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @remedy_ticket_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /remedy_ticket_configs/1
  # PUT /remedy_ticket_configs/1.xml
  def update
    @remedy_ticket_config = RemedyTicketConfig.find(params[:id])

    respond_to do |format|
      if @remedy_ticket_config.update_attributes(params[:remedy_ticket_config])
        format.html { redirect_to(@remedy_ticket_config, :notice => 'Remedy ticket config was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @remedy_ticket_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /remedy_ticket_configs/1
  # DELETE /remedy_ticket_configs/1.xml
  def destroy
    @remedy_ticket_config = RemedyTicketConfig.find(params[:id])
    @remedy_ticket_config.destroy

    respond_to do |format|
      format.html { redirect_to(remedy_ticket_configs_url) }
      format.xml  { head :ok }
    end
  end
end
