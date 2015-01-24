ActiveAdmin.register EventMetaType do
  permit_params :name, :event_type_id
  menu label: proc{ t("active_admin.menu.event_meta_type") }, parent: 'Event Types'
  actions :all, except: [:show]

  index do
    column "Название", :name
    column "Тип" do |e| e.event_type.name end
    actions
  end

  filter :name, label: "Название"

  form do |f|
    f.inputs "Тип события" do
      f.input :name, label: "Название"
      f.input :event_type_id, label: "Тип", as: :select, collection: EventType.all.map{|e| [e.name, e.id] }
    end

    f.actions
  end

end
