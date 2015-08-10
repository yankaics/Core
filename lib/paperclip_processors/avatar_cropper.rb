module Paperclip
  class AvatarCropper < Thumbnail
    def transformation_command
      current_crop_command = crop_command
      if current_crop_command
        current_crop_command + super.join(' ').sub(/ -crop \S+/, '')
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
      return nil unless target.avatar_cropping?
      target.crop_avatar = false
      " -crop '#{target.avatar_crop_w.to_i}x#{target.avatar_crop_h.to_i}+#{target.avatar_crop_x.to_i}+#{target.avatar_crop_y.to_i}' "
    end
  end
end
