#-----------------------------------------------------------------------------------------------------------------------
# Singleton class to handle caching objects.
#
# TODO: Introduce LRU Caching
# TODO: Possibly introduce Cacheable module
#-----------------------------------------------------------------------------------------------------------------------
class Cache

  private_class_method :new

  @@instance = nil

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    @nsc_connections = {}
    @cache_map = {}
  end

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def self.instance
    @@instance = new unless @@instance
    @@instance
  end

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def get key
    @cache_map[key]
  end

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def has_in_cache? key
     @cache_map.key? key
  end

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def add_to_cache key, value
    if not has_in_cache?(key)
      # Don't store reference objects
      begin
        @cache_map[key] = value.dup
      rescue TypeError
        # In which case you can't duplicate so store
        # the original value
        @cache_map[key] = value
      end
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def remove_from_cache key
    @cache_map.delete key
  end
end