#                                           Table "public.users"
#    Column   |              Type              | Collation | Nullable |
# ------------+--------------------------------+-----------+----------+
#  id         | bigint                         |           | not null |
#  name       | character varying              |           | not null |
#  email      | character varying              |           | not null |
#  created_at | timestamp(6) without time zone |           | not null |
#  updated_at | timestamp(6) without time zone |           | not null |
# Indexes:
#     "users_pkey" PRIMARY KEY, btree (id)

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.timestamps
    end
  end
end
