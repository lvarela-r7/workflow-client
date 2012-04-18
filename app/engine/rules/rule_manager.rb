=begin
#
# Loads all the rulebooks and handles fact assertion.
#
class RuleManager
  include Ruleby

  private_class_method :new
  private :load_rule_book

  @@instance = nil

  def self.instance
    @@instance = new unless @@instance
    @@instance
  end

  def initialize
    # Find all rulebooks
    rules_dir = File.expand_path(File.join(File.dirname(__FILE__), 'rules'))
    unless Dir.exists? rules_dir
      raise Exception.new 'The rules directory could not be found'
    end

    @rulebooks = []
    @engine = nil

    Dir.open(rules_dir).each do |file|
      if file.to_s =~ /_rules/
        @rulebooks << file
      end
    end
    load_rule_book
  end

  #
  #
  #
  def assert_fact fact
    if @engine
      @engine.assert fact
      @engine.match
    else
      raise Exception.new 'The engine has not been initialized'
    end
  end

  #
  #  Can be used to load/re-load the rulebooks when neeeded.
  #
  def load_rule_book
    engine :engine do |e|
      @rulebooks.each do |rulebook|
        Object.const_get(rulebook).new e do |r|
          r.rules
        end
      end
      @engine = e
    end
  end
end
=end
