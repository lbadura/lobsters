
ThinkingSphinx::Index.define :story, :with => :active_record do
  indexes description
  indexes short_id
  indexes tags(:tag), :as => :tags
  indexes title
  indexes url
  indexes user.username, :as => :author

  has created_at, :sortable => true
  has hotness, is_expired
  has "(cast(upvotes as integer) - cast(downvotes as integer))",
    :as => :score, :type => :bigint, :sortable => true

  set_property :field_weights => {
    :upvotes => 15,
    :title => 10,
    :tags => 5,
  }

  where sanitize_sql(:is_expired => false)
end
