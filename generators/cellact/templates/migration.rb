class CreateCellactLogs < ActiveRecord::Migration
  def self.up
    create_table :cellact_logs, :force => true do |t|
      t.references :cellactable, :polymorphic => true
      t.string    :kind, :limit => 10
      t.string    :status, :limit => 10
      t.string    :wire_log, :limit => 1024
      t.timestamps
    end

  end
  
  def self.down
    drop_table :cellact_logs
  end
end