module ActiveRecord
  module Associations
    module ClassMethods
      @@valid_keys_for_belongs_to_association << :with_deleted
    end

    class BelongsToAssociation
      private
      def find_target
        find_method = if @reflection.options[:primary_key]
                        "find_by_#{@reflection.options[:primary_key]}"
                      else
                        "find"
                      end

        options = @reflection.options.dup

        (options.keys - [:select, :include, :readonly, :with_deleted]).each do |key|
          options.delete key
        end
        options[:conditions] = conditions

        if( @owner[@reflection.primary_key_name] )
          the_target = options.delete(:with_deleted) ? @reflection.klass.send(:unscoped) : @reflection.klass
          the_target = the_target.send(
            find_method,
            @owner[@reflection.primary_key_name],
            options
          )
        end
        set_inverse_instance(the_target, @owner)

        the_target
      end
    end

    class BelongsToPolymorphicAssociation
      private
      def find_target
        puts @reflection.options[:foreign_type].inspect
        puts @owner[@reflection.options[:foreign_type]]
        return nil if association_class.nil?

        target =
          if @reflection.options[:conditions]
            association_class.find(
              @owner[@reflection.primary_key_name],
              :select     => @reflection.options[:select],
              :conditions => conditions,
              :include    => @reflection.options[:include]
            )
          else
            puts "#{@reflection.options[:with_deleted]}"
            target_class = @reflection.options[:with_deleted] ? \
              association_class.send(:unscoped) : association_class

            target_class.find(
              @owner[@reflection.primary_key_name],
              :select => @reflection.options[:select],
              :include => @reflection.options[:include]
            )
          end
        set_inverse_instance(target, @owner)
        target
      end
    end
  end
end
