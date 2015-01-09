# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

cities = City.create([
    { name: 'Харьков' },
    { name: 'Киев' },
    { name: 'Львов' },
    { name: 'Днепропетровск' },
    { name: 'Одесса' },
    { name: 'Москва' },
    { name: 'Санкт-Петербург' }
  ])
puts "Created default cities"
event_types = EventType.create([
    { name: 'Активный отдых' },
    { name: 'Саморазвитие' },
    { name: 'Романтический отдых' },
    { name: 'Отдых компанией' },
    { name: 'Семейный отдых' },
    { name: 'Мастер-классы' }
  ])
puts "Create default event types"
event_meta_types = EventMetaType.create([
    {name: 'Утренник', event_type: 'семейный отдых'},
    {name: 'Ночной клуб', event_type: 'отдых компанией'}
  ])
puts "Create defaul event meta types"

admin = User.create( email: 'simplicate@yandex.ua', password: 11111111, admin: true, avatar_attributes: { remote_attachment_url: 'http://cs418519.vk.me/v418519728/2641/ABb0UMUFshI.jpg' } )
user  = User.create( email: 'khahapx@gmail.com', password: 11111111, admin: false )
puts "Create default admin and user"

user.events.create([
    {
      name: "Детский утренник на первое января",
      event_type: 'утренник',
      teaser: 'Начало в 8:00, билеты: 25 грн. детский, 50 грн. взрослый. Продолжительность 1 час.',
      city: 'Харьков',
      content: '<h1>Очень интересный детский утренник!</h1>',
      images: 'http://terenkur.com/system/events/images/000/014/143/original/0Wqx0RXzPqk.jpg?1420153238'
    },
    {
      name: "Студенческая вечеринка",
      event_type: 'ночной клуб',
      teaser: 'Начало в 23:00, билеты: 100 грн, депозит за столик: 300 грн. До 6 утра.',
      city: 'Харьков',
      content: '<h2>Оторвемся!</h2>',
      images: [
        'http://terenkur.com/system/events/images/000/011/440/original/903063.jpg?1418295839',
        'http://terenkur.com/system/events/images/000/009/137/original/-yOI8b8tdbU.jpg?1416956553'
      ]
    }
  ])
puts "Create test event"