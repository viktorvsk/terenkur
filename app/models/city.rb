class City < ActiveRecord::Base
  include Permalinkable
  has_many :events, dependent: :destroy

  def self.get_all_vk
    t1 = Time.now
    res = all.map{ |c| c.get_vk_events }
    t2 = Time.now
    res << (t2 - t1)
    res
  end

  def get_vk_events
    city_id = JSON.parse(Conf['vk.main_cities'])[self.name.mb_chars.downcase.to_s]
    return "Для города #{self.name} парсинг не проработан" unless city_id
    token   = Conf['vk.token']
    words   = Conf['vk.words'].split("\n") + EventType.keywords
    words << self.name
    evs     = Event.from_vk_by_words(words, city_id)
    evs     = Event.vk_to_events(evs, self)
    Event.create_or_update_from_api(evs, User.first, initial_count: evs.count)
  end
end
