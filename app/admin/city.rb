ActiveAdmin.register City do
  permit_params :name, :permalink, :vk_public_url
  actions :all, except: [:show]

  menu priority: 4, label: proc{ t("active_admin.menu.cities") }

  index do
    column "Название", :name
    column "Ссылка", :permalink
    actions
  end

  filter :name, label: "Название"
  filter :permalink, label: "Ссылка"

  form do |f|
    f.inputs "Тип события" do
      f.input :name, label: "Название"
      f.input :vk_public_url, label: "ID паблика Вконтакте"
      f.input :permalink, label: "Ссылка"
    end

    f.actions
  end

end
