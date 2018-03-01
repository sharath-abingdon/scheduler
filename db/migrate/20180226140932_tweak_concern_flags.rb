class TweakConcernFlags < ActiveRecord::Migration
  def change
    rename_column :concerns, :controls, :edit_any
    add_column    :concerns, :subedit_any, :boolean, default: false
  end
end
