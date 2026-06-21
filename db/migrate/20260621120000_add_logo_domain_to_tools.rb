class AddLogoDomainToTools < ActiveRecord::Migration[7.1]
  def change
    add_column :tools, :logo_domain, :string
  end
end
