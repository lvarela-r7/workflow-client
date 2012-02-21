require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))

class CVSSRule < IntegerRangeRule

  @MIN_SCORE = 0
  @MAXX_SCORE = 10

end