# This migration comes from planning_engine (originally 20180626121135)
class AddParentToIntervention < ActiveRecord::Migration[4.2]
  def change
    add_column :interventions, :parent_id, :integer
  end
end
