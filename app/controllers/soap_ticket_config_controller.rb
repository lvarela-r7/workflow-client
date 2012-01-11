class SoapTicketConfigController < ApplicationController
  # GET /soap_ticket_config
  # GET /soap_ticket_config.xml
  def index
    @soap_ticket_config = SOAPTicketingConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @soap_ticket_config }
    end
  end

  # GET /soap_ticket_config/1
  # GET /soap_ticket_config/1.xml
  def show
    @soap_ticket_config = SOAPTicketingConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @soap_ticket_config }
    end
  end

  # GET /soap_ticket_config/new
  # GET /soap_ticket_config/new.xml
  def new
    @soap_ticket_config = SOAPTicketingConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @soap_ticket_config }
    end
  end

  # GET /soap_ticket_config/1/edit
  def edit
    @soap_ticket_config = SOAPTicketingConfig.find(params[:id])
  end

  # POST /soap_ticket_config
  # POST /soap_ticket_config.xml
  def create
    @soap_ticket_config = SOAPTicketingConfig.new(params[:soap_ticket_config])

    respond_to do |format|
      if @soap_ticket_config.save
        format.html { redirect_to(@soap_ticket_config, :notice => 'SOAP ticket config was successfully created.') }
        format.xml { render :xml => @soap_ticket_config, :status => :created, :location => @soap_ticket_config }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @soap_ticket_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /soap_ticket_config/1
  # PUT /soap_ticket_config/1.xml
  def update
    @soap_ticket_config = SOAPTicketingConfig.find(params[:id])

    respond_to do |format|
      if @soap_ticket_config.update_attributes(params[:soap_ticket_config])
        format.html { redirect_to(@soap_ticket_config, :notice => 'SOAP ticket config was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @soap_ticket_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /soap_ticket_config/1
  # DELETE /soap_ticket_config/1.xml
  def destroy
    @soap_ticket_config = SOAPTicketingConfig.find(params[:id])
    @soap_ticket_config.destroy

    respond_to do |format|
      format.html { redirect_to(soap_ticket_config_url) }
      format.xml { head :ok }
    end
  end
end
