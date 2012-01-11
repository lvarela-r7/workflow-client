class TicketMappingsController < ApplicationController
  # GET /ticket_mappings
  # GET /ticket_mappings.xml
  def index
    @ticket_mappings = TicketMapping.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @ticket_mappings }
    end
  end

  # GET /ticket_mappings/1
  # GET /ticket_mappings/1.xml
  def show
    @ticket_mapping = TicketMapping.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @ticket_mapping }
    end
  end

  # GET /ticket_mappings/new
  # GET /ticket_mappings/new.xml
  def new
    @ticket_mapping = TicketMapping.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @ticket_mapping }
    end
  end

  # GET /ticket_mappings/1/edit
  def edit
    @ticket_mapping = TicketMapping.find(params[:id])
  end

  # POST /ticket_mappings
  # POST /ticket_mappings.xml
  def create
    @ticket_mapping = TicketMapping.new(params[:ticket_mapping])

    respond_to do |format|
      if @ticket_mapping.save
        format.html { redirect_to(@ticket_mapping, :notice => 'Ticket mapping was successfully created.') }
        format.xml { render :xml => @ticket_mapping, :status => :created, :location => @ticket_mapping }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @ticket_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ticket_mappings/1
  # PUT /ticket_mappings/1.xml
  def update
    @ticket_mapping = TicketMapping.find(params[:id])

    respond_to do |format|
      if @ticket_mapping.update_attributes(params[:ticket_mapping])
        format.html { redirect_to(@ticket_mapping, :notice => 'Ticket mapping was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @ticket_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ticket_mappings/1
  # DELETE /ticket_mappings/1.xml
  def destroy
    @ticket_mapping = TicketMapping.find(params[:id])
    @ticket_mapping.destroy

    respond_to do |format|
      format.html { redirect_to(ticket_mappings_url) }
      format.xml { head :ok }
    end
  end
end
