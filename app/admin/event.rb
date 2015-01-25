ActiveAdmin.register Event do
  permit_params :name, :permalink, :user_id, :city_id, :address, :content, :teaser, :min_price, :max_price
  actions :all, except: [:show]

  menu priority: 3, label: proc{ t("active_admin.menu.events") }

  before_filter only: [:edit, :update, :destroy] do
    @event ||= Event.find_by_permalink(params[:id])
  end

  index do
    column "Название", :name do |event|
      link_to(event.name, event_path(event)) +
      tag(:br) +
      content_tag(:b, [
        event.event_type.name,
        event.created_at,
        "Участников: #{event.orders.count}"
      ].join((', ')))
    end
    column "Организатор", :user do |event|
      link_to(event.user.name, user_path(event.user))
    end
    actions
  end

  filter :name, label: "Название"
  filter :permalink, label: "Ссылка"
  filter :days_name_gteq, label: 'Дата', as: :datepicker
  filter :user_admin_eq, label: 'Создано админом', as: :select, collection: [['Да',true],['Нет',false]]
  filter :user_id_eq, label: "Организатор", as: :select, collection: User.all.map{ |u| ["#{u.name} (#{u.email})", u.id] }
  filter :city_id_eq, label: "Город", as: :select, collection: City.all.map{ |c| [c.name, c.id] }
  filter :event_type_id_eq, label: "Тип события", as: :select, collection: EventType.all.map{ |et| [et.name, et.id] }

  form do |f|
    f.inputs "Тип события" do
      f.input :name, label: "Название"
      f.input :permalink, label: "Ссылка"
      f.input :user
      f.input :city
      f.input :address
      f.input :teaser
      f.input :min_price
      f.input :max_price
      f.cktext_area :content, input_html: { type: :textarea }
    end

    f.actions
  end

end
