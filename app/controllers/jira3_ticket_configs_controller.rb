class Jira3TicketConfigsController < ApplicationController
  # GET /jira3_ticket_configs
  # GET /jira3_ticket_configs.xml
  def index
    @jira3_ticket_configs = Jira3TicketConfig.all

    respond_to do |format|
      format.html # index.html.haml.old
      format.xml  { render :xml => @jira3_ticket_configs }
    end
  end

  # GET /jira3_ticket_configs/1
  # GET /jira3_ticket_configs/1.xml
  def show
    @jira3_ticket_config = Jira3TicketConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @jira3_ticket_config }
    end
  end

  # GET /jira3_ticket_configs/new
  # GET /jira3_ticket_configs/new.xml
  def new
    @jira3_ticket_config = Jira3TicketConfig.new

    respond_to do |format|
      format.html # new.html.haml
      format.xml  { render :xml => @jira3_ticket_config }
    end
  end

  # GET /jira3_ticket_configs/1/edit
  def edit
    @jira3_ticket_config = Jira3TicketConfig.find(params[:id])
  end

  # POST /jira3_ticket_configs
  # POST /jira3_ticket_configs.xml
  def create
    @jira3_ticket_config = Jira3TicketConfig.new(params[:jira3_ticket_config])

    respond_to do |format|
      if @jira3_ticket_config.save
        format.html { redirect_to(@jira3_ticket_config, :notice => 'Jira3 ticket config was successfully created.') }
        format.xml  { render :xml => @jira3_ticket_config, :status => :created, :location => @jira3_ticket_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @jira3_ticket_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /jira3_ticket_configs/1
  # PUT /jira3_ticket_configs/1.xml
  def update
    @jira3_ticket_config = Jira3TicketConfig.find(params[:id])

    respond_to do |format|
      if @jira3_ticket_config.update_attributes(params[:jira3_ticket_config])
        format.html { redirect_to(@jira3_ticket_config, :notice => 'Jira3 ticket config was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @jira3_ticket_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /jira3_ticket_configs/1
  # DELETE /jira3_ticket_configs/1.xml
  def destroy
    @jira3_ticket_config = Jira3TicketConfig.find(params[:id])
    @jira3_ticket_config.destroy

    respond_to do |format|
      format.html { redirect_to(jira3_ticket_configs_url) }
      format.xml  { head :ok }
    end
  end
end
