class VkCityParser
  @queue = :vk_parser

  def self.perform(city_id)
    city = City.find(city_id)
    city.get_vk_events
  end
end