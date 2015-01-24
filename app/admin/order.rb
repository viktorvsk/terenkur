ActiveAdmin.register Order do
  permit_params :event_id, :user_id
  actions :all, except: [:show]

  menu priority: 2, label: proc{ t("active_admin.menu.orders") }

  index do
    column "Заказ", :name do |order|
      [
        order.user.name,
        order.user.phone,
        order.user.email
      ].join(', ')
    end
    column "Событие", :link do |order|
      link_to order.event.name, event_path(order.event)
    end
    column "Организатор", :owner do |order|
      link_to order.event.user.name, user_path(order.event.user)
    end
    actions
  end

  filter :user, label: "Клиент"
  filter :event, label: "Событие"
  filter :event_user_id_eq, label: 'Организатор', as: :select, collection: User.all.map{ |u| [u.name, u.id] }
  filter :created_at, label: "Дата"

  form do |f|
    f.inputs "Тип события" do
      f.input :user
      f.input :event
    end

    f.actions
  end

end
