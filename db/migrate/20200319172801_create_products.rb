#                                           Table "public.products"
#    Column    |              Type              | Collation | Nullable |
# -------------+--------------------------------+-----------+----------+
#  id          | bigint                         |           | not null |
#  user_id     | bigint                         |           | not null |
#  name        | character varying              |           | not null |
#  expiry_date | date                           |           | not null |
#  quantity    | integer                        |           | not null |
#  created_at  | timestamp(6) without time zone |           | not null |
#  updated_at  | timestamp(6) without time zone |           | not null |
# Indexes:
#     "products_pkey" PRIMARY KEY, btree (id)
#     "index_products_on_user_id" btree (user_id)
# Foreign-key constraints:
#     "fk_rails_dee2631783" FOREIGN KEY (user_id) REFERENCES users(id)
class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :name, null: false
      t.date :expiry_date, null: false
      t.integer :quantity, null: false
      t.timestamps
    end
  end
end
