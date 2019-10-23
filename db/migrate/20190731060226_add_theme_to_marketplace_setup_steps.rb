class AddThemeToMarketplaceSetupSteps < ActiveRecord::Migration[5.1]
  def change
    add_column :marketplace_setup_steps, :theme, :boolean, default: false
  end
end
