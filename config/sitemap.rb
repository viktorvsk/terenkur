host "www.new.terenkur.com"

# Basic sitemap – you can change the name :site as you wish
sitemap :site do
  url root_url, last_mod: Time.now, change_freq: "daily", priority: 1.0
  url page_path(:parnters), last_mod: Time.now, change_freq: "monthly", priority: 0.9
  url page_path(:about), last_mod: Time.now, change_freq: "monthly", priority: 0.9
  url users_url, last_mod: User.order('updated_at DESC').first.update_at
  # City.where(true).each do |city|
  #   last_mod = city.events.order('created_at DESC').first.try(:created_at) || Time.now
  #   url search_url(city: city.permalink), last_mod: last_mod, priority: 0.8, change_freq: "dayli"
  # end
  # EventType.where(true).each do |event_type|
  #   last_mod = event_type.events.order('created_at DESC').first.try(:created_at) || Time.now
  #   url search_url(type: event_type.permalink), last_mod: last_mod, priority: 0.8, change_freq: "dayli"
  # end
  # Event.where(true).each do |event|
  #   url event_url(event), last_mod: event.updated_at, change_freq: "weekly", priority: 0.7
  # end
  User.where(true).each do |user|
    url user_url(user), last_mod: user.updated_at, change_freq: "weekly", priority: 0.6
  end

end



# Pings search engines after generation has finished
#ping_with "http://#{host}/sitemap.xml"