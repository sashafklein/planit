module PlanMod
  class Manifester

    attr_accessor :plan
    def initialize(plan)
      @plan = plan
    end

    def add_to_manifest(object:, location: nil, before: nil, remove_from_list: true)
      raise "Conflicting manifest location arguments!" if location && before

      index = location || manifest_location(before) || plan.manifest.length
      insert! object, index
    end

    def remove_from_manifest(object:, location: nil)
      remove(object, location); plan.save!
      plan.manifest
    end

    def move_in_manifest(from:, to:)
      move(from, to); plan.save!
      plan.manifest
    end

    def objects
      @objects ||= plan.manifest.map{ |i| i['class'].constantize.find(i.id) }
    end

    private

    def move(from, to)
      plan.manifest_will_change!
      manidup = plan.manifest.dup

      object = manidup[from]
      insert_index = ( from < to ? to - 1 : to )

      manidup.delete_at from
      manidup.insert(insert_index, object)

      plan.manifest = manidup
    end

    def remove(object, location=nil)
      plan.manifest_will_change!
      manidup = plan.manifest.dup

      if location
        manidup.delete_at location if indices(object).include?(location)
      else
        manidup.delete hashify(object)
      end

      plan.manifest = manidup
    end

    def manifest_location(before)
      indices(before).first if before
    end

    def hashify(object)
      return object if object.is_a?(Hash)
      hash = { class: object.class.to_s, id: object.id }
      hash[:detail] = hash_detail(object)
      hash.stringify_keys
    end

    def insert!(object, index)
      insert(object, index); plan.save!
      plan.manifest
    end

    def insert(object, index)
      manidup = plan.manifest.dup
      plan.manifest_will_change!
      manidup.insert index, hashify(object) 
      plan.manifest = manidup
    end

    def indices(object)
      is = []
      plan.manifest.each_with_index{ |o, i| is << i if o == hashify(object) }
      is
    end

    def hash_detail(object)
      case object.class.to_s
      when 'Item' then object.meta_category
      else ''
      end
    end
  end
end