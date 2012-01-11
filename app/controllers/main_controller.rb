require File.expand_path(File.join(File.dirname(__FILE__), '../engine/logging/log_manager'))

class MainController < ApplicationController

  #
  #
  #
  def index
    logger = LogManager.instance
    log_array = logger.get_log_body
    @logs = ""
    log_array.each do |line|
      @logs << prettify(line)
    end
  end

  #
  #
  #
  def get_log
    logger = LogManager.instance
    current_line = (params[:line] || 0).to_i
    lines = logger.get_messages_since_line current_line
    logs = ""
    lines.each do |line|
      logs << prettify(line)
    end

    render :text => logs, :content_type => Mime::HTML
  end

  #
  #
  #
  def prettify(line)
    ltype = case line[0, 3]
              when '[-]'
                'error'
              when '[+]'
                'good'
              when '[!]'
                'status'
              else
                'normal'
            end

    if line =~ /^\[/
      line = line[3, line.length-1]
    end

    "<div class=\"logline_#{ltype}\">#{line}</div>"
  end
end
