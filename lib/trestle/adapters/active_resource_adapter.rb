module Trestle
  module Adapters
    module ActiveResourceAdapter
      def collection(params={})
        model.all
      end

      def find_instance(params)
        model.find(params[:id])
      end

      def build_instance(attrs={}, params={})
        model.new(attrs)
      end

      def update_instance(instance, attrs, params={})
        instance.assign_attributes(attrs)
      end

      def save_instance(instance, params={})
        instance.save
      end

      def delete_instance(instance, params={})
        instance.destroy
      end

      def merge_scopes(scope, other)
        scope.merge(other)
      end

      def count(collection)
        collection.count
      end

      def sort(collection, field, order)
        collection.reorder(field => order)
      end

      def default_table_attributes
        default_attributes.reject do |attribute|
          inheritance_column?(attribute)
        end
      end

      def default_form_attributes
        default_attributes.reject do |attribute|
          primary_key?(attribute) || inheritance_column?(attribute)
        end
      end

      protected

      def default_attributes
        model.fields.map do |field_name, field_type|
          Attribute.new(field_name, field_type)
        end
      end
      # def default_attributes
      #   model.db_schema.map do |column_name, column_attrs|
      #     if column_name.to_s.end_with?("_id") && (name = column_name.to_s.sub(/_id$/, '')) && (reflection = model.association_reflection(name.to_sym))
      #       Attribute::Association.new(column_name, class: -> { reflection.associated_class }, name: name)
      #     else
      #       Attribute.new(column_name, column_attrs[:type])
      #     end
      #   end
      # end

      def primary_key?(attribute)
        attribute.name.to_s == model.primary_key
      end

      # def inheritance_column?(attribute)
      #   model.respond_to?(:sti_key) && attribute.name.to_s == model.sti_key.to_s
      # end
    end
  end
end
