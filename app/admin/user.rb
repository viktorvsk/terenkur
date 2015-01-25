ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :name, :phone,
                :about, :birthdate, :admin, :sex
  actions :all, except: [:show]
  menu priority: 7

  index do
    column "Информация", :info do |user|
      [
        user.name,
        user.email,
        user.phone,
        "Событий: #{user.events.count}",
        "Заказов: #{user.orders.count}"
      ].join(', ')
    end
    column "Зарегистрировался", :created_at
    actions
  end

  filter :email, label: 'Почта'
  filter :name, label: 'Имя'
  filter :phone, label: 'Телефон'
  filter :created_at, label: 'Регистрация'

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :name
      f.input :phone
      f.input :about
      f.input :birthdate
      f.input :admin
      f.input :sex, as: :select, collection: [[t('sex.form.male'),:male],[t('sex.form.female'),:female]]
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
