class NscConfigsController < ApplicationController

  # GET /nsc_configs
  # GET /nsc_configs.xml
  def index
    @nsc_configs = NscConfig.all

    respond_to do |format|
      format.html # index.html.haml.old.erb
      format.xml { render :xml => @nsc_configs }
    end
  end

  # GET /nsc_configs/1
  # GET /nsc_configs/1.xml
  def show
    @nsc_config = NscConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @nsc_config }
    end
  end

  # GET /nsc_configs/new
  # GET /nsc_configs/new.xml
  def new
    @nsc_config = NscConfig.new

    respond_to do |format|
      format.html # new.html.haml
      format.xml { render :xml => @nsc_config }
    end
  end

  # GET /nsc_configs/1/edit
  def edit
    @nsc_config = NscConfig.find(params[:id])
  end

  # POST /nsc_configs
  # POST /nsc_configs.xml
  def create
    # Let hope we never have to localize :)
    if not is_connection_test?
      @nsc_config = NscConfig.new(params[:nsc_config])

      respond_to do |format|
        if @nsc_config.save
          host = @nsc_config[:host]
          conn_manager = NSCConnectionManager.instance
          conn_manager.add_connection @nsc_config
          ScanSummariesManager.load_by_host(host, conn_manager.get_nsc_connection(host))
          format.html { redirect_to '/nsc_configs' }
          format.xml { render :xml => @nsc_config, :status => :created, :location => @nsc_config }
        else
          format.html { render :action => "new" }
          format.xml { render :xml => @nsc_config.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # TODO: Ensure this updates the scan pollers as well.
  # PUT /nsc_configs/1
  # PUT /nsc_configs/1.xml
  def update

    if not is_connection_test?
      @nsc_config = NscConfig.find(params[:id])

      respond_to do |format|
        if @nsc_config.update_attributes(params[:nsc_config])
          NSCConnectionManager.instance.update_connection @nsc_config
          format.html { redirect_to '/nsc_configs' }
          format.xml { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml { render :xml => @nsc_config.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /nsc_configs/1
  # DELETE /nsc_configs/1.xml
  def destroy
    consoles = NscConfig.find params[:nexpose_console_ids]

    NscConfig.destroy_all :id => consoles.map(&:id)

    # Now remove from the connection manager
    consoles.each do |console|
      NSCConnectionManager.instance.remove_connection console
    end

    respond_to do |format|
      format.html { redirect_to(nsc_configs_url) }
      format.xml { head :ok }
    end
  end

  def is_connection_test?
    if params[:commit] =~ /^Test/
      if NSCConnectionManager.is_alive? params[:nsc_config]
        flash[:notice] = 'Good'
      else
        flash[:notice] = 'Bad'
      end

      @nsc_config = NscConfig.new(params[:nsc_config])
      render '_form'
      true
    else
      false
    end
  end
end
