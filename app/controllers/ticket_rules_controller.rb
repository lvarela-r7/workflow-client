class TicketRulesController < ApplicationController
  # GET /ticket_rules
  # GET /ticket_rules.xml
  def index
    @ticket_rules = TicketRule.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ticket_rules }
    end
  end

  # GET /ticket_rules/1
  # GET /ticket_rules/1.xml
  def show
    @ticket_rule = TicketRule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ticket_rule }
    end
  end

  # GET /ticket_rules/new
  # GET /ticket_rules/new.xml
  def new
    @ticket_rule = TicketRule.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ticket_rule }
    end
  end

  # GET /ticket_rules/1/edit
  def edit
    @ticket_rule = TicketRule.find(params[:id])
  end

  # POST /ticket_rules
  # POST /ticket_rules.xml
  def create
    @ticket_rule = TicketRule.new(params[:ticket_rule])

    respond_to do |format|
      if @ticket_rule.save
        format.html { redirect_to(@ticket_rule, :notice => 'Ticket rule was successfully created.') }
        format.xml  { render :xml => @ticket_rule, :status => :created, :location => @ticket_rule }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ticket_rule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ticket_rules/1
  # PUT /ticket_rules/1.xml
  def update
    @ticket_rule = TicketRule.find(params[:id])

    respond_to do |format|
      if @ticket_rule.update_attributes(params[:ticket_rule])
        format.html { redirect_to(@ticket_rule, :notice => 'Ticket rule was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ticket_rule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ticket_rules/1
  # DELETE /ticket_rules/1.xml
  def destroy
    @ticket_rule = TicketRule.find(params[:id])
    @ticket_rule.destroy

    respond_to do |format|
      format.html { redirect_to(ticket_rules_url) }
      format.xml  { head :ok }
    end
  end
end
