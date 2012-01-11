class ModulesController < ApplicationController
  def index
    @modules = ModuleType.all
  end
end