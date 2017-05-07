class AddResultToRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :result, :float
  end
end
