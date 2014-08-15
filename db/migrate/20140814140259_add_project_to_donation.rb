class AddProjectToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :project, :string
  end
end
