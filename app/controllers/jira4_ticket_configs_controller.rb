class Jira4TicketConfigsController < ApplicationController
  # GET /jira4_ticket_configs
  # GET /jira4_ticket_configs.xml
  def index
    @jira4_ticket_configs = jira4TicketConfig.all

    respond_to do |format|
      format.html # index.html.haml.old
      format.xml  { render :xml => @jira4_ticket_configs }
    end
  end

  # GET /jira4_ticket_configs/1
  # GET /jira4_ticket_configs/1.xml
  def show
    @jira4_ticket_config = jira4TicketConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @jira4_ticket_config }
    end
  end

  # GET /jira4_ticket_configs/new
  # GET /jira4_ticket_configs/new.xml
  def new
    @jira4_ticket_config = jira4TicketConfig.new

    respond_to do |format|
      format.html # new.html.haml
      format.xml  { render :xml => @jira4_ticket_config }
    end
  end

  # GET /jira4_ticket_configs/1/edit
  def edit
    @jira4_ticket_config = jira4TicketConfig.find(params[:id])
  end

  # POST /jira4_ticket_configs
  # POST /jira4_ticket_configs.xml
  def create
    @jira4_ticket_config = jira4TicketConfig.new(params[:jira4_ticket_config])

    respond_to do |format|
      if @jira4_ticket_config.save
        format.html { redirect_to(@jira4_ticket_config, :notice => 'jira4 ticket config was successfully created.') }
        format.xml  { render :xml => @jira4_ticket_config, :status => :created, :location => @jira4_ticket_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @jira4_ticket_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /jira4_ticket_configs/1
  # PUT /jira4_ticket_configs/1.xml
  def update
    @jira4_ticket_config = jira4TicketConfig.find(params[:id])

    respond_to do |format|
      if @jira4_ticket_config.update_attributes(params[:jira4_ticket_config])
        format.html { redirect_to(@jira4_ticket_config, :notice => 'jira4 ticket config was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @jira4_ticket_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /jira4_ticket_configs/1
  # DELETE /jira4_ticket_configs/1.xml
  def destroy
    @jira4_ticket_config = jira4TicketConfig.find(params[:id])
    @jira4_ticket_config.destroy

    respond_to do |format|
      format.html { redirect_to(jira4_ticket_configs_url) }
      format.xml  { head :ok }
    end
  end
end
