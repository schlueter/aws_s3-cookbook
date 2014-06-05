actions :create, :delete, :retrieve
default_action :create

attribute :name,           :kind_of => String, :name_attribute => true
attribute :bucket,         :kind_of => String, :required => true
attribute :content,        :kind_of => String
attribute :file,           :kind_of => String
attribute :content_type,   :kind_of => String
attribute :make_public,    :kind_of => [TrueClass, FalseClass], :default => false
