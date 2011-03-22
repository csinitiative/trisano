# TODO: Remove after upgrading past Rails 2.3.8
module ActiveRecord::Reflection

  class AssociationReflection
    def collection?
      if @collection.nil?
        @collection = [:has_many, :has_and_belongs_to_many].include?(macro)
      end
      @collection
    end
  end

end
