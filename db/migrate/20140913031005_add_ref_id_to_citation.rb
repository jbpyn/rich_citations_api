class AddRefIdToCitation < ActiveRecord::Migration

  def up
    # Do this in two steps because SQLLite is a pain
    add_column    :citations, :ref, :string, limit: 255
    change_column :citations, :ref, :string, limit: 255, :null => false
  end

  def down
    remove_column :citations, :ref
  end

end
