ActiveAdmin.register EventType do
  permit_params :name, :permalink
  actions :all, except: [:show]

  index do
    column "Название", :name
    column "Ссылка", :permalink
    actions
  end

  filter :name, label: "Название"
  filter :permalink, label: "Домен"

  form do |f|
    f.inputs "Тип события" do
      f.input :name, label: "Название"
      f.input :permalink, label: "Ссылка"
    end

    f.actions
  end

end
