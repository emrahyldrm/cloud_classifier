class ChangeTypeAddProbToRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :prob, :string
    change_column :requests, :result, :string
  end
end
