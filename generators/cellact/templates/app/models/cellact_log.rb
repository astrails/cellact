class CellactLog < ActiveRecord::Base
  belongs_to :cellactable, :polymorphic => true
  attr_accessible :all
end