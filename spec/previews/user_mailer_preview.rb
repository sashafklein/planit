class UserMailerPreview < ActionMailer::Preview

  def welcome_waitlist
    UserMailer.welcome_waitlist( User.first.atts(:email, :first_name, :last_name) )
  end

  def welcome_invited
    UserMailer.welcome_invited( User.first.atts(:email, :first_name, :last_name) )
  end

  def welcome_invited_with_inviter
    UserMailer.welcome_invited( User.first.atts(:email, :first_name, :last_name), User.last.casual_name )
  end

  # def share_love_user_guides
  #   url = "https://plan.it/users/" + User.first.slug + "/guides?y=in_2015"
  #   object = User.first
  #   new_share = Share.create(sharer: User.first, sharee: User.last, url: url, object: object, notes: "Hey this is awesome!")
  #   UserMailer.share_love(share_id: new_share.id)
  # end

  # def share_love_user_places
  #   url = "https://plan.it/users/" + User.first.slug + "/places?f=food+drink"
  #   object = User.first
  #   new_share = Share.create(sharer: User.first, sharee: User.last, url: url, object: object, notes: "Hey this is awesome!")
  #   UserMailer.share_love(share_id: new_share.id)
  # end

  def share_plan
    url = "https://plan.it/plans/" + Plan.first.id.to_s + "?q=tokyo+tea+time"
    object = Plan.first
    new_share = Share.create( sharer: User.first, sharee: User.last, url: url, object: object, notes: "Hey this is awesome!")
    UserMailer.share_plan( share_id: new_share.id, email: User.last.email )
  end

end