module Ripped
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def ripped?
    ripped.present?
  end

  def ripped_on_discogs?
    # is there data? is there notes? is there a field for 'RIP notes' and is it empty?
    return false if data.nil? || data["notes"].nil? || data["notes"].select {|el| el["field_id"] == 3}.empty?

    data["notes"].select {|el| el["field_id"] == 3}[0]["value"].match?(/rip/i)
  end

  def ripped_on_discogs!(wrapper, username, folder_id, release_id, instance_id, field_id, data = {})
    wrapper.edit_field_on_instance_in_user_folder(username, folder_id, release_id, instance_id, field_id, data)
  end

  module ClassMethods
    def ripped
      where(ripped: true)
    end
  end
end
