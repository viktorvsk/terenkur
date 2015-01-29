# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

City.create([
      { name: 'Харьков', permalink: 'kharkov', currency: 'грн.', vk_public_url: '78864351' },
      { name: 'Киев', currency: 'грн.' },
      { name: 'Львов', currency: 'грн.' },
      { name: 'Днепропетровск', currency: 'грн.' },
      { name: 'Одесса', currency: 'грн.' },
      { name: 'Москва', currency: 'руб.' },
      { name: 'Санкт-Петербург', currency: 'руб.' }
    ])
    puts "Created default cities"
    EventType.create([
      { name: 'Активный отдых' },
      { name: 'Саморазвитие' },
      { name: 'Романтический отдых' },
      { name: 'Отдых компанией', keywords: "веселиться\nгулять\nвечеринка" },
      { name: 'Семейный отдых', keywords: "спектакль\nутренник" },
      { name: 'Мастер-классы', keywords: "мастер-класс\nлекция" }
    ])
    puts "Create default event types"
    EventMetaType.create([
      {name: 'Утренник', event_type: 'семейный отдых'},
      {name: 'Ночной клуб', event_type: 'отдых компанией'}
    ])

    puts "Create defaul event meta types"
    Conf['popup.title']       = 'Регистрируйтесь, у нас круто!'
    Conf['popup.body']        = '<h1>Очень</h1>'
    Conf['popup.version']     = 9
    Conf['popup.timer']       = 15
    Conf['deletions.1']       = 'Сервис ИНФОПАРК — это наиболее удобный и комфортный способ приобрести билеты на творческие вечера любимых исполнителей и актеров, посетить интерисующие семинары и тренинги. Чтобы не терять ни капли времени, сделайте заказ прямо сейчас и получите свою порцию наслаждения уже в ближайшее время!'
    Conf['deletions.2']       = 'Показать полностью...'
    Conf['welcome.header']    = 'Добро пожаловать в Теренкур'
    Conf['welcome.message']   = '<p>Мы знаем все о событиях</p>'
    User.create(
      email: 'robot@terenkur.com',
      name: 'Роботос',
      password: Devise.friendly_token.first(16),
      avatar_attributes: { attachment: File.new("#{Rails.root}/app/assets/images/robot.png") }
      )
    User.create(
      email: 'simplicate@yandex.ua',
      password:  Devise.friendly_token.first(16),
      admin: true,
      name: "Виктор"
      )