class AddFreeTimeFields < ActiveRecord::Migration[5.2]
  def change
    add_column :freefinders, :ft_start_date,    :date
    add_column :freefinders, :ft_num_days,      :integer
    add_column :freefinders, :ft_days,          :text
    add_column :freefinders, :ft_day_starts_at, :time
    add_column :freefinders, :ft_day_ends_at,   :time
    add_column :freefinders, :ft_element_ids,   :text

    add_column :settings, :ft_default_num_days,      :integer, default: 14
    add_column :settings,
               :ft_default_days,
               :text,
               default: "---\n- false\n- true\n- true\n- true\n- true\n- true\n- false\n"
    add_column :settings, :ft_default_day_starts_at, :time,
      default: Time.find_zone("UTC").parse("08:30")
    add_column :settings, :ft_default_day_ends_at,   :time,
      default: Time.find_zone("UTC").parse("17:30")
  end
end
