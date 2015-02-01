class City < ActiveRecord::Base
  include Permalinkable
  has_many :events, dependent: :destroy

  def self.get_all_vk
    t1 = Time.now
    all.map{ |c| c.get_vk_events }
    t2 = Time.now
    t2 - t1
  end

  def get_vk_events
    city    = JSON.parse(Conf['vk.main_cities'])[self.name.mb_chars.downcase.to_s]
    return "Для города #{self.name} парсинг не проработан" unless city
    token   = Conf['vk.token']
    words   = Conf['vk.words'].split("\n")
    words << self.name
    result  = []
    words.each do |word|
      url = "https://api.vk.com/method/groups.search?q=#{word}&access_token=#{token}&count=1000&future=1&city_id=#{city}&type=event"
      url = URI.encode(url)
      begin
        response = RestClient.get(url)
      rescue RestClient
        print '-'
        next
      end
      begin
        response_json_events = JSON.parse(response)['response'][1..-1]
      rescue NoMethodError
        print '-'
        next
      end
      result << response_json_events
      print '+'
      sleep 0.333

    end
    evs = result.flatten.select(&:present?).uniq{ |e| e['name'] }
    ids = evs.map{ |e| e['gid'] }

    result_events = []

    ids.in_groups_of(500, false) do |ids_group|
      i = ids_group.join(',')
      resp = RestClient.post("https://api.vk.com/method/groups.getById",
        group_ids: i,
        fields: 'place,description,members_count,start_date,finish_date')
      begin
        result_events << JSON.parse(resp)['response']
      rescue NoMethodError
        print '-'
        next
      end
      sleep 0.333
    end

    result_events.flatten!
    result_events.reject!{ |e| e['members_count'].to_i < 25 }

    result_events.map! do |event|
      s = Time.at(event['start_date'].to_i).to_date.strftime("%d %b %Y")
      e = Time.at(event['finish_date'].to_i).to_date.strftime("%d %b %Y")
      date = "#{s} - #{e}"
      r = {
           "name"          => event['name'],
           "content"       => event['description'],
           "date"          => date,
           "image"         => event['photo_big'],
           "teaser"        => event['description'],
           "city"          => self.name
          }
      r['address'] = event['place']['title'] if event['place'].present?
      r
    end
    Event.create_or_update_from_api(result_events, User.first, initial_count: result_events.count)
  end
end
