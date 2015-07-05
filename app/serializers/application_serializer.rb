class ApplicationSerializer < ActiveModel::Serializer
  delegate :cache_key, :to => :object

  # Cache entire JSON string
  def to_json(*args)
    Rails.cache.fetch expand_cache_key(self.class.to_s.underscore, cache_key, 'to-json') do
      super
    end
  end

  def serializable_hash
    Rails.cache.fetch expand_cache_key(self.class.to_s.underscore, cache_key, 'serilizable-hash') do
      super
    end
  end

  # Hack to make serialization of arrays use cache and include extra params
  def self.array_to_json(array, other_params = {})
    json = "{"
    other_params.each do |key, value|
      json << "\"#{key}\": #{value.to_json}, "
    end
    json << "\"result\": ["
    
    array.each do |item|
      json << self.new(item, root: false).to_json << ","
    end
    if !array.empty?
      json[0...json.length - 1] << "]}"
    else
      json << "]}"
    end
  end

  private
  def expand_cache_key(*args)
    ActiveSupport::Cache.expand_cache_key args
  end
end
