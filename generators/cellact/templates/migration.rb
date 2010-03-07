class CreateCellactLogs < ActiveRecord::Migration
  def self.up
    create_table :cellact_logs, :force => true do |t|
      t.references :cellactable, :polymorphic => true
      t.string    :status, :limit => 10
      t.string    :request, :limit => 1024
      t.string    :response, :limit => 1024
      t.timestamps
    end

  end
  
  def self.down
    drop_table :cellact_logs
  end
end